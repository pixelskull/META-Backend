#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import time
import json
import errno
import logging
import subprocess

import pika
import shutil


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


def create_dirs_if_needed(path):
    if not os.path.exists(path):
        try:
            os.makedirs(path)
        except OSError as e:
            if e.errno != errno.EEXISTS:
                logging.error("could not create folder: " + path + " due to error" + e)
                raise


def get_config(json):
    config["Host"] = "127.0.0.1"
    config["Port"] = 5672

    # transfering json info
    config["Exchange"] = json["Exchange"]
    config["Read_queue"] = json["Work_queue_name"]
    config["Read_routing_key"] = json["Work_routing_key"]

    config["Write_queue"] = json["Result_queue_name"]
    config["Write_Routing_key"] = json["Result_routing_key"]

    return config


def get_config_as_json(json):
    output = get_config(json)
    return json.dumps(output)


def deploy_service(ident, file_path, config):
    basic_path = "~/.META/services/"
    # create_folder_if_needed(basic_path)
    destination_path = basic_path + ident + "/"
    create_dirs_if_needed(destination_path)

    shutil.copy2(file_path, destination_path)

    with open(service_name, 'w') as service_config:
        service_config.write(config)

    os.chdir(destination_path)
    service_name = "ComputeUnitHandler"
    proc = subprocess.Popen([service_name], shell=True)

    result_dict = {}
    result_dict["Service_location"] = service_location
    result_dict["Service_pid"] = proc.pid

    return result_dict


####
# RabbitMQ subscriber code
####
def subscriber():
    global config
    logging.debug("-> try connection with config: " + json.dumps(config))
    connection = pika.BlockingConnection(pika.ConnectionParameters(config['Host']))
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
    body_as_json = json.loads(body)

    service_config = get_config_as_json(body_as_json)

    result_dict = deploy_service(body_as_json["Id"], body_as_json["Content"], service_config)

    publisher(json.dumps(result_dict))
    ch.basic_ack(delivery_tag=method.delivery_tag)


def publisher(message):
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


####
# Main Method
####
def main(argv):
    logging.basicConfig(filename='meta-deployment-service.log', level=logging.DEBUG)
    # loading given Config file (./RabbitMQ_conf.json)
    if not loadConfig():
        return

    logging.info("starting subscriber...")
    subscriber()


# starting main method
if __name__ == '__main__':
    main(sys.argv)
