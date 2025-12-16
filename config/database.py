import boto3
import os
from config.logger import logger

def init_dynamodb():
    """Initialize DynamoDB resource"""
    region = os.getenv('AWS_REGION', 'us-east-1')
    try:
        dynamodb = boto3.resource(
            'dynamodb',
            region_name=region
        )
        logger.info(f"DynamoDB initialized with region: {region}")
        return dynamodb
    except Exception as e:
        logger.error(f"Failed to initialize DynamoDB: {str(e)}", exc_info=True)
        raise

def get_table(dynamodb, table_name: str):
    """Get a DynamoDB table"""
    try:
        logger.debug(f"Getting DynamoDB table: {table_name}")
        return dynamodb.Table(table_name)
    except Exception as e:
        logger.error(f"Failed to get table {table_name}: {str(e)}", exc_info=True)
        raise

# Initialize DynamoDB
dynamodb = init_dynamodb()
