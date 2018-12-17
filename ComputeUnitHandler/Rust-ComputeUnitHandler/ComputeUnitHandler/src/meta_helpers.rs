pub mod file {

    use std::fs::File;
    use std::io::prelude::*;
    use serde_json;
    use AMQPConfig;

    // Helper method for reading string content of some file
    pub fn read_file(path: &String) -> String {
        let mut file = File::open(path).expect("file not found"); 
        let mut file_content = String::new(); 
        file.read_to_string(&mut file_content).expect("reading file failed.");
        file_content
    }


    // Helper method for hiding serde_json call
    pub fn deserialize_from_string(string_content: &String) -> AMQPConfig {
        serde_json::from_str(&string_content).unwrap()
    }

}


pub mod rabbit_mq {

    use amqp::*;

    pub fn create_amqp_connection(host: &str) -> Channel {
        // opening amqp connection to localhost 
        let url = format!("amqp://{}/", host);
        println!("{:?}", &url.to_string());
        let mut session = Session::open_url(url.as_str()).unwrap();
        session.open_channel(1).unwrap()
    }

    pub fn amqp_consumer(channel: &mut Channel, deliver: protocol::basic::Deliver, headers: protocol::basic::BasicProperties, body: Vec<u8>) {

    }

}