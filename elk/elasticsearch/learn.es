POST products/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "range": {
          "date": {
            "gte": "now-4y"
          }
        }
      }
    }
  }
}

GET products/_mapping


POST products/_search
{
  "profile": "true",
  "explain": true,
  "query": {
    "constant_score": {
      "filter": {
        "term": {
          "avaliable": true
        }
      }
    }
  }
}

POST products/_search
{
  "profile": "true",
  "explain": true,
  "query": {
    "term": {
      "avaliable": true
    }
  }
}