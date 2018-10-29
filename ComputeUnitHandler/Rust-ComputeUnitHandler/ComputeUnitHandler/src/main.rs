extern crate amqp;

use amqp::Session;

fn main() {
    let mut session = Session::open_url("amqp://localhost//").unwrap();
    let mut _channel = session.open_channel(1).unwrap();
    println!("Hello, world!");
}
