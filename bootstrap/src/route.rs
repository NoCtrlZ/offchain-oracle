use swish_swish::*;
use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize)]
struct Response {
    code: u16,
    msg: String,
}

pub fn hello_world(_: &Request) -> Box<dyn Body> {
    Box::new(Json(Response {
        code: 200,
        msg: "hello world".to_string(),
    }))
}
