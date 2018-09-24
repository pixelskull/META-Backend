# META-Backend
Backend for the META-Compute-Framework


# About: 
META is the attempt to create a Zero-Configuration-Distribution-Framework with Mobile-Developers in mind. With META Developers
will use their mobile centered code and deploy it to the Backend-Server so that the execution will be distributed. This should
be done via small changes to the IDE and the code, this way no knowledge will be needed to execute compute intensive tasks. 


# Dependencies: 
Note that you will need to install RabbitMQ for this Project. RabbitMQ is needed for the connections of the services. 

You can install RabbitMQ via Docker the easy way, just use: 

```docker pull rabbitmq```


# Installation: 
At the moment META will only work as intended on macOS. That said other Plattforms will be supported in the future. 

1. clone this repository onto your server 
2. execute the **installBackend.sh** skript (this will configure your home folder the needed way)
3. go to *Initialization* folder and execute **startServices.sh** 

The Backend services for the compilation part will start running. You can now deploy your Compute-Units onto your server. 

The second Part of the META-Backend can be found in the *Production* folder. This Part of the Backend will communicate between 
your Frontend and the Backend-Service deployed by the *Initialization* part of the Backend. 
