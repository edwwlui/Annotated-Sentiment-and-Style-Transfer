# Background
1. It is from [[paper]](https://arxiv.org/pdf/1804.06437.pdf) Delete, Retrieve, Generate: A Simple Approach to Sentiment and Style Transfer.
2. official [README.md](https://github.com/lijuncen/Sentiment-and-Style-Transfer)

# High-Level Summary

- Part 0: input arguments
  - process
    - train
    - test
  - model_name
    - DeleteAndRetrieve
    - DeleteOnly
  - data_name
    - yelp
      - dict_num: 7000
      - dict_threshold: 15
      - {0: negative, 1: postive}
    - amazon
      - dict_num: 10000
      - dict_threshold: 5.5
      - {0: negative, 1: postive}
    - imagecaption
      - dict_num: 3000
      - dict_threshold: 5
      - {0: humorous, 1: romantic}
- Part 1: configure
  - model_name -> $main_function
    - if $main_function='DeleteOnly' -> $main_function='label'
    - if $main_function='DeleteAndRetrieve' or 'RetrieveOnly' -> $main_function='orgin'
- Part 2: train 
  - get tf-idf score from data #fw: sentiment.train.\[0,1].tf_idf.$main_function:\[label,orgin]
  - if data=amazon: use nltk to filter by tf-idf 
     - #overwrite: sentiment.train.${i:\[1,2]}.tf_idf.$main_function:\[label,orgin]
  - add if data pass threshold 
    - #fw: sentiment.train.${i:\[1,2]}.data.operation
    - #fw: sentiment.dev.${i:\[1,2]}.data.operation
  - integrate all training and testing files into
    - train.data.${main_function:\[label,orgin]}
    - test.data.${main_function:\[label,orgin]}
  - shuffle
    - #fw: train.data.${main_function:\[label,orgin]}.shuffle
    - #fw: test.data.${main_function:\[label,orgin]}.shuffle
    - append them and overwrite to the initial train.data.${main_function:\[label,orgin]}
   - create dict data file by putting in train.data.${main_function:\[label,orgin]}
     - #fw: zhi.dict.$main_function:\[label,orgin]
  - train
    - python src/main.py ../model $train_data_file $dict_data_file src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderDT train $batch_size
    

# Annotation
Start reading from run.sh

- Comment line: summary
  
- A:\[b,c] means elements b,c in set A
  
- fw: file write

