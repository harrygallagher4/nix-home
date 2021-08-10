#!zsh

git add flake.lock
git commit -m 'update flake.lock'

git tag `date +%Y.%-m.%-d` -m "$(jq -rf inputs.jq flake.lock)"

git tag -n10 `date +%Y.%-m.%-d`

