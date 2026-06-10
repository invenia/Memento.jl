#!/usr/bin/env julia
# Find all registered dependents of a package and scan their source for pattern matches.
#
# Usage:
#   julia --project=scripts scripts/depcheck.jl --help
#
# Output: all dependents, every matching line, then a per-package summary.

using ArgParse
using DataFrames
using Dates
using Downloads
using Pkg
using TOML

const PKG_SERVER = "https://pkg.julialang.org"

# 3-arg Memento-style @test_throws call where the first argument looks like a
# logger, i.e. contains "logger" in any case (logger, LOGGER, getlogger(...)).
# Misses logger names without "logger" (e.g. TESTLOG), but those packages are
# typically caught by the literal "Memento.TestUtils" pattern.
const LOGGER_CALL = raw"@test_throws[\s(]+[^\s,)]*(?i:log)[^\s,)]*[\s,)]"

# Compile r"..." command line arguments into a Regex; everything else matches literally.
function parse_pattern(s::AbstractString)
    m = match(r"^r\"(.*)\"$", s)
    return m === nothing ? s : Regex(m.captures[1])
end

pattern_label(p::AbstractString) = "\"$p\""
pattern_label(p::Regex) = "r\"$(p.pattern)\""

function parse_commandline()
    settings = ArgParseSettings(description="Scan registered dependents of a package with source pattern matches.")
    @add_arg_table! settings begin
        "--pkg"
        help = "package whose registered dependents are scanned"
        default = "Memento"
        "patterns"
        help = "patterns matched line-by-line; r\"...\" arguments are compiled as regexes (e.g., 'r\"$LOGGER_CALL\"')"
        nargs = '*'
    end

    args = parse_args(settings)
    return args["pkg"], map(parse_pattern, args["patterns"])
end

# ── Registry access ───────────────────────────────────────────────────────────
# The General registry is usually a single compressed General.toml whose contents
# live in `registry.in_memory_registry` (rel_path => raw TOML), but falls back to the
# on-disk tree for git-cloned registries
function registry_toml(registry, parts...)
    rel = join(parts, "/")
    mem = registry.in_memory_registry
    path = joinpath(registry.path, rel)

    return if mem !== nothing && haskey(mem, rel)
        TOML.parse(mem[rel])
    elseif isfile(path)
        TOML.parsefile(path)
    else
        nothing
    end
end

# Grab the UUID for a package by name
function uuid(registry, name)
    id = findfirst(pkg -> pkg.name == name, registry.pkgs)
    id === nothing && error("Package '$name' not found in registry")
    return string(id)
end

# Map of pkg_name => (uuid, path) for every package depending on `target_uuid`.
function dependents(registry, target_uuid)
    dependents = Iterators.filter(registry.pkgs) do (uuid, pkg)
        deps = registry_toml(registry, pkg.path, "Deps.toml")
        deps !== nothing && any(d -> target_uuid in values(d), values(deps))
    end
    return Dict(pkg.name => (uuid=string(uuid), path=pkg.path) for (uuid, pkg) in dependents)
end

# Latest registered release of a package as (version, sha, date), all Union{T,Missing}.
# Date comes from the registry's git checkout and is `missing` for the compressed .toml form.
function latest_release(registry, pkg_path)
    getdate(dir) =
        try
            @assert isdir(joinpath(dir, ".git"))
            raw = readchomp(`git -C $dir log --format=%as -1 -- $pkg_path/Versions.toml`)
            @assert !isempty(raw)
            return Date(raw)
        catch
            missing
        end

    versions = registry_toml(registry, pkg_path, "Versions.toml")
    (versions === nothing || isempty(versions)) && return (version=missing, sha=missing, date=missing)

    ver = argmax(VersionNumber, keys(versions))
    sha = get(versions[ver], "git-tree-sha1", missing)
    git_dir = replace(registry.path, r"\.toml$" => "")
    return (version=ver, sha=sha, date=getdate(git_dir))
end

# Download a package tarball and scan its .jl files, returning a row per line
# matching any pattern, or `missing` on download/extraction failure.
function scan_source(uuid, sha, patterns)
    tmpdir = mktempdir()

    try
        tarball = joinpath(tmpdir, "pkg.tar.gz")
        Downloads.download("$PKG_SERVER/package/$uuid/$sha", tarball)
        run(pipeline(`tar -xzf $tarball -C $tmpdir`; stderr=devnull))

        hits = NamedTuple[]
        for (root, _, files) in walkdir(tmpdir), name in filter(endswith(".jl"), files)
            path = joinpath(root, name)
            for (lineno, line) in enumerate(eachline(path))
                i = findfirst(p -> occursin(p, line), patterns)
                i === nothing && continue
                push!(hits, (
                    file=relpath(path, tmpdir),
                    line=lineno,
                    pattern=pattern_label(patterns[i]),
                    code=strip(line),
                ))
            end
        end

        return hits
    catch e
        @warn "Could not fetch/scan $uuid@$sha" exception = e
        return missing
    finally
        rm(tmpdir; recursive=true, force=true)
    end
end

target_pkg, patterns = parse_commandline()
general = only(filter(r -> r.name == "General", Pkg.Registry.reachable_registries()))
target_uuid = uuid(general, target_pkg)
deps = sort(collect(dependents(general, target_uuid)); by=first)

println("Target  : $target_pkg ($target_uuid)")
println("Patterns: $(join(map(pattern_label, patterns), ", "))")
println("\nAll registered dependents ($(length(deps))):")
foreach(d -> println("  ", first(d)), deps)
println()

match_rows, summary_rows = NamedTuple[], NamedTuple[]
for (name, info) in deps
    print("Scanning $name … ")
    rel = latest_release(general, info.path)
    hits = ismissing(rel.sha) ? missing : scan_source(info.uuid, rel.sha, patterns)
    println(ismissing(hits) ? "scan failed" : "$(length(hits)) match(es)")

    ismissing(hits) || append!(match_rows, [(package=name, h...) for h in hits])
    push!(summary_rows, (
        package=name,
        version=rel.version,
        last_release=rel.date,
        matches=ismissing(hits) ? missing : length(hits),
    ))
end

println("\nAll matches ($(length(match_rows)) line(s)):")
isempty(match_rows) || show(DataFrame(match_rows); allrows=true, allcols=true, truncate=100)

println("\n\nSummary by package:")
summary = sort!(DataFrame(summary_rows), [order(:matches; by=m -> coalesce(m, -1), rev=true), :package])
show(summary; allrows=true, allcols=true)
println()
