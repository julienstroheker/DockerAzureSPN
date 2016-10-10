# DockerAzureSPN

Create an SPN application on your Azure Subscription and attribute the collaborator rights on it.

## Context

If you need to interact with Microsoft Azure through some external services like Visual Studio Team Services (VSTS) 
or your own Web Application you will need to create an application to interact with your subscription.

I developed this shell script using the Azure-CLI to automate the process of creation a SPN in the desired Azure Subscription.

Output Example :

```
================== Informations about your new App ==============================
Subscription ID                    XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX
Subscription Name                  Your Subscription Name
Service Principal Client ID:       XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX
Service Principal Key:             YourPasswordOrGeneratingARandomOne
Tenant ID:                         XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXX
=================================================================================
```

## Usage

You must have docker installed and run the following command :

```
docker run -it julienstroheker/dockerazurespn <NameApp> <PasswordApp>
```

You must remplace the `<NameApp>` variable with the name of the application that you want to create and the `<PasswordApp>` with password that you want.

>Note : the `<PasswordApp>` is optional, if you are not specify one, it will generate one for you

## Run locally without Docker

You can run the azaddspn.sh script on your machine if you have a MAC or Linux machine.

You may need some prerequisites tools installed like : jq / awk / azure-cli...