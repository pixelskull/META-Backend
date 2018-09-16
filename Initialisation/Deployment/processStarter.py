#!/usr/bin/python
# -*- coding: utf-8 -*-
import subprocess

def startProcess(service_path):
  service = subprocess.Popen([service_path])
  result_dict = {}
  result_dict["Service_location"] = service_path
  result_dict["Service_pid"] = service.pid

  return result_dict
