const express = require('express')
const app = express()
const port = 5000

app.get('/', (req, res) => {
  res.json({data: {price: 25}})
})

app.listen(port, () => {
  console.log(`app listening at http://localhost:${port}`)
})
