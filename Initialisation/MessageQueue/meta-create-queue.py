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

def createQueueWith(ident, suffix, host = "127.0.0.1", exchange = "meta.production"):

    connection = pika.BlockingConnection(pika.ConnectionParameters(host))
    logging.info("connection to server established...")
    channel = connection.channel()
    channel.confirm_delivery()
    logging.info("channel successfully created...")

    queue_id = ident + "-" + suffix
    full_queue_name = exchange + "." + queue_id
    # declaring queue for new Service (md5 hash id)
    channel.queue_declare(queue=full_queue_name)
    logging.info("queue successfully declared...")
    # bind new queue to production exchange with id as routing key
    channel.queue_bind(exchange=exchange,
                       queue=full_queue_name,
                       routing_key=queue_id)
    logging.debug("bind queue " + full_queue_name + " to Exchange " + exchange + " with key " + queue_id)
    # closing connectiin no longer needed
    connection.close()
    logging.info("closed connection to rabbitMQ instance...")

    return queue_id


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
    global config
    json_data = json.loads(body)

    work_queue_id = createQueueWith(json_data["Id"], "-work", config["Host"])
    result_queue_id = createQueueWith(json_data["Id"], "-result", config["Host"])

    # add new information to message
    exchange = "meta.production"

    json_data['Work_queue_name']    = exchange + "." + work_queue_id
    json_data['Exchange']           = exchange
    json_data['Work_routing_key']   = work_queue_id

    json_data['Result_queue_name']  = exchange + "." + result_queue_id
    json_data['Result_routing_key'] = result_queue_id

    # and publish
    publish(json_string)
    ch.basic_ack(delivery_tag=method.delivery_tag)



####
# RabbitMQ publisher code
####

# publishes given message to queue
def publish(message):
    global config
    try:
        connection = pika.BlockingConnection(pika.ConnectionParameters(config['Host']))
        logging.info("connection to server established...")
        channel = connection.channel()
        logging.info("channel successfully created...")
        channel.queue_declare(queue=config['Write_queue'])
        logging.info("queue successfully declared...")
        channel.basic_publish(exchange=config['Exchange'],
                                routing_key=config['Routing_key'],
                                body=message)

        logging.info("message successfully published...")
        connection.close()
    except:
        logging.error('could not publish message due to unexpected error')


def main():
    logging.basicConfig(filename='meta-create-queue-service.log', level=logging.DEBUG)
    # loading given Config file (./RabbitMQ_conf.json)
    if not loadConfig():
        return
    # starting subscriber
    subscriber()


# starting main method
if __name__ == '__main__':
    main()
