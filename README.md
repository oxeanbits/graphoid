# Digitalize Upgrade to rails 7 and Upgrade of Graphql Ruby

```
sudo apt-get install libssl1.1
rvm install ruby-3.2.2 --with-yjit --with-openssl-dir=/opt/openssl-1.1.1q/
```

## Testing

http://127.0.0.1:3000/graphiql

# roadmap

- [x] single query project { }
- [x] many query projects { }
- [x] where query projects(where: { }) { }
- [x] order query projects(order: { }) { }
- [x] create mutation createProject { }
- [x] update mutation updateProject { }
- [x] delete mutation deleteProject { }
- [x] query with nested fields single on result projects { example { text } }
- [x] query with nested fields on result projects { examples { text } }
- [x] overcoming circular dependency on types (used string types declaration)
- [x] query with nested fields on where projects(where: { example: { text: "test" } }) { }
- [x] query with nested fields on result and where projects { examples(where: ...) { text } }
- [ ] Improve initialization and module enabling on models
- [ ] enable graphields
- [ ] enable graphorbid
- [ ] tests


# Working without crashes but no native eager load

{
  testField
  example {
    dateTime
    date
    time
    timestamp
    text
    bigInt
    decimal
    hashField
    array
  }
  project(where:{
    OR: [{nameIn: ["Test"]}]
  }) {
    id name createdAt updatedAt active

  }
  projects(order: { name: DESC}, where: { active: true}) {
    active
    name
    id
    createdAt
    updatedAt
  }
}


mutation m{
  createProject(data: {
    name: "Jhon"
  }) {
    id
    name
  }
}


## References

https://graphql-ruby.org/queries/ast_analysis.html
