"""Return text streams to EDAM data.

Keep parsing and such to minimum to maintain maximum backward compatibility.
"""
from io import TextIOWrapper
from typing import TextIO

from pkg_resources import resource_stream


def tabular_stream() -> TextIO:
    """Yield EDAM data in TSV format as a Python UTF-8 encoded text stream."""
    return TextIOWrapper(resource_stream("edam_ontology", 'EDAM.tsv'), encoding='utf-8')
