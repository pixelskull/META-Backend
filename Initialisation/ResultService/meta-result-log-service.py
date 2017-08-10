#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import json
import pika
import logging


config = {}

def loadConfig():
    exists = os.path.isfile('./rabbitMQ_conf.json')
    if exists:
        logging.debug("-> loading \'rabbitMQ_conf.json\': file exists")
        f = open('./rabbitMQ_conf.json', 'r')
        content = f.read()
        json_data = json.loads(content)

        global config
        config = json_data
        return True
    else:
        logging.error("could not load \'rabbitMQ_conf.json\'")
        return False


####
# RabbitMQ subscriber code
####

def subscriber():
    global config
    logging.debug("-> try connection with config: " + json.dumps(config))
    connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
    logging.info("connection to server established...")
    channel = connection.channel()
    channel.confirm_delivery()
    logging.info("channel successfully created...")
    channel.queue_declare(queue=config['Read_queue'])
    logging.info("queue successfully declared...")
    # tell rabbitMQ to not send more than one message to this worker
    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(callback_subscriber,
                          queue=config['Read_queue'])
    logging.info("start consuming from queue...")
    channel.start_consuming()


def callback_subscriber(ch, method, properties, body):
    logging.info("---> Recieved: " + body)



def main():
    logging.basicConfig(filename='meta-result-log-service.log', level=logging.DEBUG)
    # loading given Config file (./RabbitMQ_conf.json)
    if not loadConfig():
        return
    # starting subscriber
    subscriber()


# starting main method
if __name__ == '__main__':
    main()
