extern crate amqp;

#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate serde_json;

use std::fs::File;
use std::io::prelude::*;

use amqp::Session;


#[derive(Serialize, Deserialize, Debug)]
struct AMQPConfig {
    host:           String, 
    port:           u8, 
    read_queue:     String, 
    exchange:       String, 
    write_queue:    String,
    routing_key:    String, 
    user:           String, 
    password:       String  
}

fn read_file(path: String) -> String {
    let mut file = File::open(path).expect("file not found"); 
    let mut file_content = String::new(); 
    file.read_to_string(&mut file_content).expect("reading file failed.");
    file_content
}

fn deserialize_from_string(string_content: String) -> AMQPConfig {
    serde_json::from_str(&string_content).unwrap()
}

fn main() {
    let mut session = Session::open_url("amqp://localhost//").unwrap();
    let mut _channel = session.open_channel(1).unwrap();

    let file_content = read_file("../misc/amqp.json.example".to_string()); 
    let _conf = deserialize_from_string(file_content);
}
