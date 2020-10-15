mod route;

extern crate swish_swish;

use swish_swish::*;
use route::hello_world;

fn swish_swish() -> Swish {
    let mut swish = Swish::new();
    swish.get("/", hello_world);
    swish.set_cors_as(allow_everything());
    swish
}

fn main() {
    swish_swish().bish();
}
