# Health Cards

## Linting

```shell
be rubocop -c .rubocop.yml
```
[Rubocop will automatically traverse up the parent tree](https://github.com/rubocop/rubocop/issues/536) and 
find the `.rubocop.yml` and try to require `rubocop-rails` if `-c .rubocop.yml` is not employed