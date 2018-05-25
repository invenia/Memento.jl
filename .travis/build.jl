if VERSION > v"0.7.0-DEV.3656"
    using OldPkg
    OldPkg.clone(pwd())
    OldPkg.build("Memento")
else
    Pkg.clone(pwd())
    Pkg.build("Memento")
end