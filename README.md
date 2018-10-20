# Background
1. It is from [[paper]](https://arxiv.org/pdf/1804.06437.pdf) Delete, Retrieve, Generate: A Simple Approach to Sentiment and Style Transfer.
2. official [README.md](https://github.com/lijuncen/Sentiment-and-Style-Transfer)

# High-Level Summary

- part 1 configuration
- part 2 train 
  - get tf-idf score from data #fw: sentiment.train.\[0,1].tf_idf.$main_function:\[label,orgin]
  - if data=amazon: use nltk to filter by tf-idf 
     - #overwrite: sentiment.train.${i:\[1,2]}.tf_idf.$main_function:\[label,orgin]
  - add if data passes threshold 
    - #fw: sentiment.train.${i:\[1,2]}.data.operation
    - #fw: sentiment.dev.${i:\[1,2]}.data.operation
  - integrate all training and testing files into
    - train.data.${main_function:\[label,orgin]}
    - test.data.${main_function:\[label,orgin]}
  - shuffle
    - #fw: train.data.${main_function:\[label,orgin]}.shuffle
    - #fw: test.data.${main_function:\[label,orgin]}.shuffle
    - append
    
    #cat test.data.${main_function:\[label,orgin]}.shuffle >>train.data.${main_function:\[label,orgin]}.shuffle
    - overwrite initial train.data.${main_function:\[label,orgin]}
    
    #cp train.data.${main_function:\[label,orgin]}.shuffle $train.data.${main_function:\[label,orgin]}
   - make dict data file by train.data.${main_function:\[label,orgin]}
     - #fw: zhi.dict.$main_function:\[label,orgin]
  - train
    - python src/main.py ../model $train_data_file $dict_data_file src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderDT train $batch_size
    

# Annotation
Start reading from run.sh

- Comment line: summary
  
- A:\[b,c] means elements b,c in set A
  
- fw: file write

