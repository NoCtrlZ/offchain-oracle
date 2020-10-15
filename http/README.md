# Http Client
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
