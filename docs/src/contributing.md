## Get started contributing

Detailed docs on contributing to Julia packages can be found [here](http://docs.julialang.org/en/stable/manual/packages/#package-development).

### Code and docs

To start hacking code or writing docs, simply:

1. `julia> Pkg.add("Memento"); Pkg.checkout("Memento")`
2. Make your changes.
3. Test your changes with `julia --compilecache=no -e 'Pkg.test("Memento"; coverage=true)'`
4. Check that your changes haven't reduced the test coverage. From the root Memento package folder run `julia -e 'using Coverage; Coverage.get_summary(process_folder())'`.
5. Make a pull request to [Memento](https://github.com/invenia/Memento.jl) and share your changes with the rest of the community.

### Bugs, features, and requests

Feel free to [file issues](https://github.com/invenia/Memento.jl/issues) when you encounter bugs, think of interesting features you'd like to see, or when there are important changes not yet included in a release and you'd like us to tag a new version.

## Submitting your contributions

*By contributing code to Memento, you are agreeing to release your work under the [MIT License](https://github.com/invenia/Memento.jl/blob/master/LICENSE).*

We love contributions in the form of pull requests! Assuming you've been working in a repo checked out as above, this should be easy to do. For a detailed walkthrough, check [here](https://help.github.com/articles/fork-a-repo), otherwise:

1. Navigate to [Memento.jl](https://github.com/invenia/Memento.jl) and create a fork.
2. `git remote add origin https://github.com/user/Memento.jl.git`
3. `git push origin master`
4. Submit your changes as a pull request!

For pull requests to be accepted we require that the changes:

1. Pass on travis and appveyor
2. Maintain [100% test coverage](http://myronmars.to/n/dev-blog/2012/05/in-defense-of-100-test-coverage)
