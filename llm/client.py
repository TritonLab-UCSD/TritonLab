"""Single place for LLM calls so prompts, logging, and cost tracking stay consistent."""

import os

from dotenv import load_dotenv

load_dotenv()


def complete(prompt: str, system: str = "", max_tokens: int = 800) -> str:
    """Send one prompt to the LLM and return the text reply."""
    import anthropic  # imported lazily so tests don't require the SDK

    client = anthropic.Anthropic(api_key=os.environ["LLM_API_KEY"])
    response = client.messages.create(
        model=os.environ["LLM_MODEL"],
        max_tokens=max_tokens,
        system=system,
        messages=[{"role": "user", "content": prompt}],
    )
    return "".join(block.text for block in response.content if block.type == "text")
