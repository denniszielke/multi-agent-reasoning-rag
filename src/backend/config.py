# config.py
import logging
import os
#autogen changes
#from autogen_ext.models.openai import AzureOpenAIChatCompletionClient
from autogen_core.components.models import AzureOpenAIChatCompletionClient
from azure.cosmos.aio import CosmosClient
from azure.identity import (ClientSecretCredential, DefaultAzureCredential, get_bearer_token_provider)
from azure.core.credentials import AzureKeyCredential
from azure.search.documents import SearchClient
from dotenv import load_dotenv
from openai import AzureOpenAI

load_dotenv()


def GetRequiredConfig(name):
    return os.environ[name]


def GetOptionalConfig(name, default=""):
    if name in os.environ:
        return os.environ[name]
    return default


def GetBoolConfig(name):
    return name in os.environ and os.environ[name].lower() in ["true", "1"]



class Config:
    AZURE_TENANT_ID = GetOptionalConfig("AZURE_TENANT_ID")
    AZURE_CLIENT_ID = GetOptionalConfig("AZURE_CLIENT_ID")
    AZURE_CLIENT_SECRET = GetOptionalConfig("AZURE_CLIENT_SECRET")

    COSMOSDB_ENDPOINT = GetRequiredConfig("COSMOSDB_ENDPOINT")
    COSMOSDB_DATABASE = GetRequiredConfig("COSMOSDB_DATABASE_NAME")
    COSMOSDB_CONTAINER = GetRequiredConfig("COSMOSDB_CONTAINER_NAME")

    AZURE_OPENAI_DEPLOYMENT_NAME = GetRequiredConfig("AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME")
    AZURE_OPENAI_API_VERSION = GetRequiredConfig("AZURE_OPENAI_API_VERSION")
    AZURE_OPENAI_SMALL_COMPLETION_DEPLOYMENT_NAME = GetRequiredConfig("AZURE_OPENAI_SMALL_COMPLETION_DEPLOYMENT_NAME")
    AZURE_OPENAI_SMALL_COMPLETION_MODEL_VERSION = GetRequiredConfig("AZURE_OPENAI_SMALL_COMPLETION_MODEL_VERSION")

    AZURE_OPENAI_ENDPOINT = GetRequiredConfig("AZURE_OPENAI_ENDPOINT")
    AZURE_OPENAI_API_KEY = GetOptionalConfig("AZURE_OPENAI_API_KEY")

    FRONTEND_SITE_NAME = GetOptionalConfig("FRONTEND_SITE_NAME", "http://127.0.0.1:3000")
    
    AI_SEARCH_ENDPOINT = GetRequiredConfig("AI_SEARCH_ENDPOINT")
    AI_SEARCH_INDEX = GetRequiredConfig("AI_SEARCH_INDEX")

    AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME = GetRequiredConfig("AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME")
    AZURE_OPENAI_EMBEDDING_MODEL = GetRequiredConfig("AZURE_OPENAI_EMBEDDING_MODEL")

    __azure_credentials = DefaultAzureCredential()
    __comos_client = None
    __cosmos_database = None
    __search_client = None
    __azure_openai_client = None
    __aoai_chatCompletionClient = None
    __aoai_smallchatCompletionClient = None

    def GetAzureCredentials():
        # If we have specified the credentials in the environment, use them (backwards compatibility)
        if all(
            [Config.AZURE_TENANT_ID, Config.AZURE_CLIENT_ID, Config.AZURE_CLIENT_SECRET]
        ):
            return ClientSecretCredential(
                tenant_id=Config.AZURE_TENANT_ID,
                client_id=Config.AZURE_CLIENT_ID,
                client_secret=Config.AZURE_CLIENT_SECRET,
            )

        # Otherwise, use the default Azure credential which includes managed identity
        return Config.__azure_credentials

    def GetSearchClient():
        if Config.__search_client is None:

            Config.__search_client = SearchClient(
                endpoint=Config.AI_SEARCH_ENDPOINT,
                index_name=Config.AI_SEARCH_INDEX,
                credential=Config.GetAzureCredentials()
            )

        return Config.__search_client

    def GetOpenAIClient():
        if Config.__azure_openai_client is None:
            Config.__azure_openai_client = AzureOpenAI(
                azure_ad_token_provider=Config.GetTokenProvider(
                    "https://cognitiveservices.azure.com/.default"
                ),
                api_version=Config.AZURE_OPENAI_API_VERSION,
                azure_endpoint=Config.AZURE_OPENAI_ENDPOINT,
            )

        return Config.__azure_openai_client

    def GetEmbedding(input: str):
        return Config.GetOpenAIClient().embeddings.create(input=input, model = Config.AZURE_OPENAI_EMBEDDING_MODEL).data[0].embedding

    # Gives us a cached approach to DB access
    def GetCosmosDatabaseClient():
        # TODO: Today this is a single DB, we might want to support multiple DBs in the future
        if Config.__comos_client is None:
            Config.__comos_client = CosmosClient(
                Config.COSMOSDB_ENDPOINT, Config.GetAzureCredentials()
            )

        if Config.__cosmos_database is None:
            Config.__cosmos_database = Config.__comos_client.get_database_client(
                Config.COSMOSDB_DATABASE
            )

        return Config.__cosmos_database

    def GetTokenProvider(scopes):
        return get_bearer_token_provider(Config.GetAzureCredentials(), scopes)

    def GetAzureOpenAIChatCompletionClient(model_capabilities):
        if Config.__aoai_chatCompletionClient is not None:
            return Config.__aoai_chatCompletionClient

        if Config.AZURE_OPENAI_API_KEY == "":
            # Use DefaultAzureCredential for auth
            Config.__aoai_chatCompletionClient = AzureOpenAIChatCompletionClient(
                model=Config.AZURE_OPENAI_DEPLOYMENT_NAME,
                api_version=Config.AZURE_OPENAI_API_VERSION,
                azure_endpoint=Config.AZURE_OPENAI_ENDPOINT,
                azure_ad_token_provider=Config.GetTokenProvider(
                    "https://cognitiveservices.azure.com/.default"
                ),
                model_capabilities=model_capabilities,
                temperature=0,
            )
        else:
            # Fallback behavior to use API key
            Config.__aoai_chatCompletionClient = AzureOpenAIChatCompletionClient(
                model=Config.AZURE_OPENAI_DEPLOYMENT_NAME,
                api_version=Config.AZURE_OPENAI_API_VERSION,
                azure_endpoint=Config.AZURE_OPENAI_ENDPOINT,
                api_key=Config.AZURE_OPENAI_API_KEY,
                model_capabilities=model_capabilities,
                temperature=0,
            )

        return Config.__aoai_chatCompletionClient
    
    def GetSmallAzureOpenAIChatCompletionClient(model_capabilities):
        if Config.__aoai_smallchatCompletionClient is not None:
            return Config.__aoai_smallchatCompletionClient

        if Config.AZURE_OPENAI_API_KEY == "":
            # Use DefaultAzureCredential for auth
            Config.__aoai_smallchatCompletionClient = AzureOpenAIChatCompletionClient(
                model=Config.AZURE_OPENAI_SMALL_COMPLETION_DEPLOYMENT_NAME,
                api_version=Config.AZURE_OPENAI_SMALL_COMPLETION_MODEL_VERSION,
                azure_endpoint=Config.AZURE_OPENAI_ENDPOINT,
                azure_ad_token_provider=Config.GetTokenProvider(
                    "https://cognitiveservices.azure.com/.default"
                ),
                model_capabilities=model_capabilities,
                temperature=0,
            )
        else:
            # Fallback behavior to use API key
            Config.__aoai_smallchatCompletionClient = AzureOpenAIChatCompletionClient(
                model=Config.AZURE_OPENAI_SMALL_COMPLETION_DEPLOYMENT_NAME,
                api_version=Config.AZURE_OPENAI_SMALL_COMPLETION_MODEL_VERSION,
                azure_endpoint=Config.AZURE_OPENAI_ENDPOINT,
                api_key=Config.AZURE_OPENAI_API_KEY,
                model_capabilities=model_capabilities,
                temperature=0,
            )

        return Config.__aoai_smallchatCompletionClient
