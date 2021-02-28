# WordPress .pot File Generator - Github Action
This Action generates .pot file for your WordPress plugin or theme repository

## Configuration
### Required secrets
* `GITHUB_TOKEN`

[Secrets are set in your repository settings](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets). They cannot be viewed once stored.

### Other optional configuration

| Key | Default | Description |
| --- | ------- | ----------- |
| `destination_path` | ./languages | Destination path to save generated POT File |
| `slug` | Github repo name | Slug of your WordPress Plugin/Theme |
| `text_domain` | Slug of Plugin/Theme | Text Domain of WordPress Theme / Plugin |


## Example Workflow File

To get started, you will want to copy the contents of one of these examples into `.github/workflows/main.yml` and push that to your repository. You are welcome to name the file something else.

```yml
name: Generate POT file
on:
  push:
    branches:
      - develop

jobs:
  WP_Generate_POT_File:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: WordPress .pot File Generator
      uses: iamdharmesh/action-wordpress-pot-generator@main
      with:
        destination_path: './languages'
        slug: 'SLUG_OF_PLUGIN_OR_THEME'
        text_domain: 'TEXT_DOMAIN_OF_PLUGIN_OR_THEME'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
