{
  path_prefix | String | default = "",
  date        | String | default = "",
  is_local    | Bool   | default = false,

  files = {
    "tf-1-intro.adoc" = "Terraform/OpenTofu for Devs: An Introduction",
    "tf-2-project-management.adoc" = "Project Managment in OpenTofu",
    "tf-3-refactoring.adoc" = "Refactoring OpenTofu Codebases",
    "tf-4-advanced.adoc" = "Beyond the Basics in OpenTofu",
    "tf-5-complaints.adoc" = "OpenTofu: The Ugly",
  },

  by_series = {
    tf_development = {
      name =  "OpenTofu for Devs",
      list = [
        "tf-1-intro.adoc",
        "tf-2-project-management.adoc",
        "tf-3-refactoring.adoc",
        "tf-4-advanced.adoc",
        "tf-5-complaints.adoc"
      ],
    },
  },

  by_file =
    files
    |> std.record.map (fun path v => {
      title       = v,
      "%{"path"}" = path,
      series_list =
        by_series
        |> std.record.fields
        |> std.array.filter (fun id => by_series."%{id}".list |> std.array.any ((==) path))
      ,
    })
  ,

  series_adoc = by_file |> std.record.map_values (fun file => {
    title  = file.title,
    series = file.series_list
      |> std.array.map (fun series_id => by_series."%{series_id}")
      |> std.array.map (fun series => m%"
        This post is part of a series __%{series.name}__:

        %{
          series.list
          |> std.array.map (fun path =>
            let title = files."%{path}" in

            if path == file.path
            then ". %{title}"
            else ". link:<%{path_prefix}%{path}>[%{title}]"
          )
          |> std.string.join "\n"
        }

      "%)
      |> std.string.join "\n\n"
    ,
    frontmatter =
      if is_local
      then ""
      else m%"
        +++
        title  = '%{title}'
        author = 'Yueleshia'
        date   = '%{date}'
        +++
      "%
    ,
    header = m%"
      %{frontmatter}

      :toc:

      = %{title}

      ====
      %{series}
      ====

    "%,
  }),
} | {
  files | { _ | String },
  by_series | {
    _ | {
      name | String,
      list | std.contract.all_of [
        Array String,
        Array (std.contract.from_validator (fun path =>
          if files |> std.record.has_field path
          then 'Ok
          else 'Error { message = "%{path} is not present in 'files'" }
        ))
      ],
    }
  },
  ..
}
