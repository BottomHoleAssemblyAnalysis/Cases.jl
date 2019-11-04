using Documenter, BHAtp_case_01_example

makedocs(
    modules = [BHAtp_case_01_example],
    format = Documenter.HTML(),
    checkdocs = :exports,
    sitename = "BHAtp_case_01_example.jl",
    pages = Any["index.md"]
)

deploydocs(
    repo = "github.com/goedman/BHAtp_case_01_example.jl.git",
)
