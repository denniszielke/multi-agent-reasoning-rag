from typing import List

# from autogen_core import AgentId
#from autogen_core import default_subscription
#from autogen_ext.models.openai import AzureOpenAIChatCompletionClient
#from autogen_core.tools import FunctionTool, Tool

from autogen_core.base import AgentId
from autogen_core.components import default_subscription
from autogen_core.components.models import AzureOpenAIChatCompletionClient
from autogen_core.components.tools import FunctionTool, Tool

from agents.base_agent import BaseAgent
from context.cosmos_memory import CosmosBufferedChatCompletionContext

async def get_facts_about_a_company(company_name: str) -> str:
    return f"The financial for company '{company_name}' are very good."


async def get_current_stockvalue(company_name: str) -> str:
    return f"The stock'{company_name}' is at 40 dollars"

# Create the MarketingTools list
def get_financial_tools() -> List[Tool]:
    FinancialTools: List[Tool] = [
        FunctionTool(
            get_facts_about_a_company,
            description="Get financial statements about a specific company.",
            name="get_facts_about_a_company",
        ),
        FunctionTool(
            get_current_stockvalue,
            description="Get stock values about a specific company.",
            name="get_current_stockvalue",
        )
    ]
    return FinancialTools


@default_subscription
class FinancialAgent(BaseAgent):
    def __init__(
        self,
        model_client: AzureOpenAIChatCompletionClient,
        session_id: str,
        user_id: str,
        model_context: CosmosBufferedChatCompletionContext,
        financial_tools: List[Tool],
        financial_tool_agent_id: AgentId,
    ):
        super().__init__(
            "FinancialAgent",
            model_client,
            session_id,
            user_id,
            model_context,
            financial_tools,
            financial_tool_agent_id,
            "You are an AI Agent. You have knowledge about financial statements, company valuation, and financial analysis. You are being called to assist with financial analyst tasks.",
        )
