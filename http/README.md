# Roar
![npm version](https://badge.fury.io/js/hear_me_roar.svg)  
This is http light client for javascript.
```javascript
const Client = require('hear_me_roar').default

const request = () => {
    const client = new Client('localhost', 3000)
    client.get('/path').then(res => {
        console.log('Get:', res)
    })

    const sample = {
        code: 200,
        data: 'hello'
    };

    client.post('/user/register', sample).then((res) => {
        console.log('Post:', res)
    });
}

request()

```
## Install
```
$ npm install --save hear_me_roar
```
## Roadmap
- [ ] Support To Set Header
- [ ] Security Check
- [ ] Optimization
- [ ] Integration Test
- [ ] Refactoring
