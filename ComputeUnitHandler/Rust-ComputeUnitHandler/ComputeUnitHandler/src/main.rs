extern crate amqp;

#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate serde_json;

use std::fs::File;
use std::io::prelude::*;
use std::env;

use amqp::Session;


#[derive(Serialize, Deserialize, Debug)]
struct AMQPConfig {
    host:           String, 
    port:           i16, 
    read_queue:     String, 
    exchange:       String, 
    write_queue:    String,
    routing_key:    String, 
    user:           String, 
    password:       String  
}

// Helper method for reading string content of some file
fn read_file(path: &String) -> String {
    let mut file = File::open(path).expect("file not found"); 
    let mut file_content = String::new(); 
    file.read_to_string(&mut file_content).expect("reading file failed.");
    file_content
}

// Helper method for hiding serde_json call
fn deserialize_from_string(string_content: &String) -> AMQPConfig {
    serde_json::from_str(&string_content).unwrap()
}

fn main() {
    let mut session = Session::open_url("amqp://127.0.0.1//").unwrap();
    let mut _channel = session.open_channel(1).unwrap();

    let cwd = env::current_dir().unwrap(); 
    let mut path_to_config: String = cwd.into_os_string().into_string().unwrap();
    let res_path = "/misc/amqp.json.example".to_string();
    path_to_config.push_str(&res_path);
    println!("{:?}", &path_to_config);
    let file_content = read_file(&path_to_config); 
    let conf = deserialize_from_string(&file_content);

    println!("{:?}", conf);
}
