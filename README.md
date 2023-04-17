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
- [ ] query with nested fields on where projects(where: { example: { text: "test" } }) { }
- [ ] query with nested fields on result projects { example { text } }
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
