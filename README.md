# dedeadname

Automatic repo cleaning tool

```sh
$ dedeadname.sh my-config git@github.com:username/repo.git
```

## Config file

It looks like this:

```sh
NEW_EMAIL="your-new@email-address"
NEW_NAME="Your New Name"
NEW_USERNAME="your-new-github-username"

OLD_EMAILS=(
    "old@email"
    "another@old.email"
    "..."
)

OLD_USERNAMES=(
    "old-username"
    "..."
)

REPLACE_FILES=(
    "README"
    "README.*"
    "LICENSE"
    "LICENSE.*"
    "Cargo.toml"
    "Cargo.lock"

    "Gemfile"
    "Gemfile.lock"
    "*.gemspec"
)

REPLACE_PATTERNS=(
    "string to search for==>string to replace it with"
    "..."
)

```
