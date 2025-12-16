import logging
import sys

def setup_logger(name: str = __name__) -> logging.Logger:
    """Configure and return a logger instance"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout)
        ]
    )
    return logging.getLogger(name)

# Create a global logger instance
logger = setup_logger(__name__)
