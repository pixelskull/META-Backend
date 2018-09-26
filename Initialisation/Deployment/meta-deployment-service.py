#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import sys
import time
import json
import errno
import logging
import processStarter

import pika
import shutil


config = {}
logger = None


def loadConfig():
    global logger
    dir_path = os.path.dirname(os.path.realpath(__file__))
    exists = os.path.isfile(dir_path + '/rabbitMQ_conf.json')
    if exists:
        logger.debug("-> loading \'rabbitMQ_conf.json\': file exists")
        f = open(dir_path + '/rabbitMQ_conf.json', 'r')
        content = f.read()
        json_data = json.loads(content)

        global config
        config = json_data
        logger.info("RabbitMQ configuration file loaded")
        return True
    else:
        logger.error("could not load \'rabbitMQ_conf.json\'")
        print("RabbitMQ configuration file not loaded")
        return False


def create_dirs_if_needed(path):
    global logger
    if not os.path.exists(path):
        try:
            os.makedirs(path)
        except OSError as e:
            if e.errno != errno.EEXIST:
                logger.error("could not create folder: " + path + " due to error" + e)
                raise


def get_config(json):
    service_config = {}
    service_config["Host"] = "127.0.0.1"
    service_config["Port"] = 5672

    # transfering json info
    service_config["Exchange"] = json["Exchange"]
    service_config["Read_queue"] = json["Work_queue_name"]
    service_config["Read_routing_key"] = json["Work_routing_key"]

    service_config["Write_queue"] = json["Result_queue_name"]
    service_config["Write_Routing_key"] = json["Result_routing_key"]

    return service_config


def get_config_as_json(json_data):
    output = get_config(json_data)
    return json.dumps(output)


def deploy_service(ident, file_path, config):
    basic_service_path = os.path.expanduser("~") + "/.META/services/"
    programm_start_path = os.getcwd() # path where this programm is started
    # create_folder_if_needed(basic_path)
    # create_dirs_if_needed(destination_path)

    # create deployment folder
    destination_path = basic_service_path + ident + "/"
    os.chdir(destination_path)
    create_dirs_if_needed("./deployment")

    os.chdir("./deployment")

    config_name = "config.json"
    with open(config_name, 'w') as service_config:
        service_config.write(config)

    # copying service for stability and starting service
    shutil.copy2(file_path, os.getcwd())
    logger.info("copied files to cwd: " + os.getcwd())
    service_path = os.path.join(os.getcwd(), "ComputeUnitHandler")
    logger.info("new service_path: " + service_path)
    os.chdir(programm_start_path)
    result_dict = processStarter.startProcess(service_path)
    # logger.debug("-> service startet: " + str(proc))
    # result_dict = {}
    # result_dict["Service_location"] = service_path
    # result_dict["Service_pid"] = proc.pid
    logger.info("new configuration created: " + str(result_dict))

    return result_dict


####
# RabbitMQ subscriber code
####
def subscriber():
    global config
    global logger
    logger.debug("-> try connection with config: " + json.dumps(config))
    connection = pika.BlockingConnection(pika.ConnectionParameters(config['Host']))
    logger.info("connection to server established...")
    channel = connection.channel()
    channel.confirm_delivery()
    logger.info("channel successfully created...")
    channel.queue_declare(queue=config['Read_queue'])
    logger.info("queue successfully declared...")

    # tell rabbitMQ to not send more than one message to this worker
    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(callback_subscriber,
                          queue=config['Read_queue'])
    logger.info("start consuming from queue...")
    channel.start_consuming()


def callback_subscriber(ch, method, properties, body):
    global logger
    logger.info("callback fired")
    body_as_json = json.loads(body)
    # logger.info("loaded message body as json: " + body_as_json)
    service_config = get_config_as_json(body_as_json)
    # logger.info("loaded service config: " + service_config)
    result_dict = deploy_service(body_as_json["Id"], body_as_json["Content"], service_config)
    # logger.info("result config created: " + result_dict)
    publisher(json.dumps(result_dict))
    logger.info("message published")
    ch.basic_ack(delivery_tag=method.delivery_tag)


def publisher(message):
    global config
    global logger
    try:
        connection = pika.BlockingConnection(pika.ConnectionParameters(config['Host']))
        logger.info("connection to server established...")
        channel = connection.channel()
        logger.info("channel successfully created...")
        channel.queue_declare(queue=config['Write_queue'])
        logger.info("queue successfully declared...")
        channel.basic_publish(exchange=config['Exchange'],
                                routing_key=config['Routing_key'],
                                body=message)

        logger.info("message successfully published: " + message + " " + config["Write_queue"] + " " + config["Exchange"] + " " + config["Routing_key"])
        connection.close()
    except:
        logger.error('could not publish message due to unexpected error')


####
# Main Method
####
def main(argv):
    # logging.basicConfig(filename='meta-deployment-service.log', level=logging.DEBUG)
    logging.basicConfig(filename='meta-deployment-service.log', level=logging.DEBUG, datefmt='%d-%m-%Y %H:%M:%S')

    global logger
    logger = logging.getLogger(__name__)
    # logging.basicConfig(filename='ir-compilation-service.log', level=logging.DEBUG, datefmt='%d-%m-%Y %H:%M:%S')

    filehandler = logging.FileHandler('meta-deployment-service.log')
    # filehandler.setLevel(logging.DEBUG)
    logger.addHandler(filehandler)


    # loading given Config file (./RabbitMQ_conf.json)
    if not loadConfig():
        return

    logger.info("starting subscriber...")
    subscriber()


# starting main method
if __name__ == '__main__':
    main(sys.argv)
