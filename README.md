# README

```
sudo apt-get install libssl1.1
rvm install ruby-3.2.2 --with-yjit --with-openssl-dir=/opt/openssl-1.1.1q/
```

# roadmap

- [x] single query project { }
- [x] many query projects { }
- [x] where query projects(where: { }) { }
- [x] order query projects(order: { }) { }
- [x] create mutation createProject { }
- [ ] update mutation updateProject { }
- [ ] delete mutation deleteProject { }
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

