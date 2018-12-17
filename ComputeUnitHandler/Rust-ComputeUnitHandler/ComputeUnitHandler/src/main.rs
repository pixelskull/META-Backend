extern crate amqp;

mod meta_helpers;

#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate serde_json;

use std::env;
use amqp::*;

use meta_helpers::file;

#[derive(Serialize, Deserialize, Debug)]
pub struct AMQPConfig {
    host:           String, 
    port:           i16, 
    read_queue:     String, 
    exchange:       String, 
    write_queue:    String,
    routing_key:    String, 
    user:           String, 
    password:       String  
}



fn main() {
    // opening amqp connection to localhost 
    let mut session = Session::open_url("amqp://127.0.0.1/").unwrap();
    let mut _channel = session.open_channel(1).unwrap();

    // get current working dir
    let cwd = env::current_dir().unwrap(); 
    let mut path_to_config: String = cwd.into_os_string().into_string().unwrap();
    // path to config file inside of project folder (eq. ./)
    let res_path = "/misc/amqp.json.example".to_string();
    path_to_config.push_str(&res_path);
    
    // DEBUG output for testing 
    println!("{:?}", &path_to_config);

    // get configuration file content 
    let file_content = file::read_file(&path_to_config); 
    let conf = file::deserialize_from_string(&file_content); // meta_helpers.deserialize_from_string(&file_content);

    println!("{:?}", conf);
}
