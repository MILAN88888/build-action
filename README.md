# MILAN Build Acton

```
name: Release Build
on:
  release:
    types: [published]
jobs:
  build:
    name: Release Build
    runs-on: ubuntu-20.04
    steps:
      - name: Checkout code
        uses: actions/checkout@v2
      - name: Set env
        id: vars
        run: echo ::set-output name=tag::${GITHUB_REF:10}
      - name: Build
        id: build
        uses: MILAN88888/build-action@ccsnpt
        with:
          generate-zip: true
      - name: Upload release asset
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.MILAN_GITHUB_TOKEN }}
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ${{ steps.build.outputs.zip_path }}
          asset_name: ${{ github.event.repository.name }}-${{ steps.vars.outputs.tag }}.zip
          asset_content_type: application/zip
```
