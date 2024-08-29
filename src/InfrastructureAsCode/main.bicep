@description('Environment of the web app')
param environment string = 'dev'

@description('Location of services')
param location string = resourceGroup().location

var webAppName = '${uniqueString(resourceGroup().id)}-${environment}'
var appServicePlanName = '${uniqueString(resourceGroup().id)}-mpnp-asp'
var logAnalyticsName = '${uniqueString(resourceGroup().id)}-mpnp-la'
var appInsightsName = '${uniqueString(resourceGroup().id)}-mpnp-ai'
var sku = 'S1'
var registryName = '${uniqueString(resourceGroup().id)}mpnpreg'
var registrySku = 'Standard'
var imageName = 'techexcel/dotnetcoreapp'
var startupCommand = ''

// TODO: complete this script
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
    name: appServicePlanName
    location: location
    sku: {
        name: sku
        tier: 'Standard'
        size: 'S1'
    }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
    name: webAppName
    location: location
    properties: {
        serverFarmId: appServicePlan.id
        siteConfig: {
            appSettings: [
                {
                    name: 'WEBSITE_NODE_DEFAULT_VERSION'
                    value: '14.17.0'
                },
                {
                    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
                    value: reference(appInsightsName).InstrumentationKey
                },
                {
                    name: 'DOCKER_REGISTRY_SERVER_URL'
                    value: reference(registryName).loginServerUrl
                },
                {
                    name: 'DOCKER_REGISTRY_SERVER_USERNAME'
                    value: reference(registryName).adminUsername
                },
                {
                    name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
                    value: reference(registryName).adminPassword
                },
                {
                    name: 'DOCKER_CUSTOM_IMAGE_NAME'
                    value: '${imageName}'
                },
                {
                    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
                    value: 'false'
                },
                {
                    name: 'WEBSITES_PORT'
                    value: '80'
                },
                {
                    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
                    value: 'false'
                },
                {
                    name: 'WEBSITES_PORT'
                    value: '80'
                }
            ]
            alwaysOn: true
            linuxFxVersion: 'DOCKER|${imageName}'
            appCommandLine: startupCommand
        }
    }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-03-01-preview' = {
    name: logAnalyticsName
    location: location
    sku: {
        name: 'PerGB2018'
    }
}

resource appInsights 'Microsoft.Insights/components@2021-02-01-preview' = {
    name: appInsightsName
    location: location
    kind: 'web'
    properties: {
        Application_Type: 'web'
        Flow_Type: 'Redfield'
    }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
    name: registryName
    location: location
    sku: {
        name: registrySku
    }
}
