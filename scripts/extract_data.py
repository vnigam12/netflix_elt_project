import pandas as pd

def get_data():
    df = pd.read_csv("/Users/vaibhav/Desktop/data_analytics_projects/netflix_elt_project/data/raw/netflix_titles.csv")
    return df