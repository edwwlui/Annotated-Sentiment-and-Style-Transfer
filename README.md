# Background
1. It is from [[paper]](https://arxiv.org/pdf/1804.06437.pdf) Delete, Retrieve, Generate: A Simple Approach to Sentiment and Style Transfer.
2. official [README.md](https://github.com/lijuncen/Sentiment-and-Style-Transfer)

# Notes for annotation
Start reading from run.sh

- Comment line: summary
  
- A:\[b,c] means elements b,c in set A
  
- fw: file write

# High-Level Summary
- Command:
  ```
  export THEANO_FLAGS=device=cuda0,floatX=float32; 
  bash run.sh train DeleteAndRetrieve yelp;
  bash run.sh test DeleteAndRetrieve yelp
  ```
- Part 0: input arguments
  - process
    - train
    - test
  - model_name
    - DeleteAndRetrieve
    - DeleteOnly
  - data_name
  
      ||dict_num|dict_threshold|data name: 0|data name: 1|output name: 0|output name: 1|
      |---|---|---|---|---|---|---|
      |yelp|7000|15|-ve|+ve|-ve to +ve|+ve to -ve|
      |amazon|10000|5.5|-ve|+ve|-ve to +ve|+ve to -ve|
      |imagecaption|3000|5|humorous|romantic|factual to romantic|factual to humorous|
- Part 1: configure
  - model_name -> $main_function
    - if $main_function=='DeleteOnly' then $main_function='label'
    - if $main_function=='DeleteAndRetrieve' or 'RetrieveOnly' then $main_function='orgin'
- Part 2: train 
  - get tf-idf score by n-gram from data 
    - #fw: sentiment.train.\[0,1].tf_idf.$main_function:\[label,orgin]
  - if data==amazon: use nltk to filter by tf-idf 
     - #overwrite: sentiment.train.${i:\[1,2]}.tf_idf.$main_function:\[label,orgin]
  - add data if pass the threshold specified 
    - #fw: sentiment.train.${i:\[0,1]}.data.${main_function:[label,orgin]}
    - #fw: sentiment.dev.${i:\[0,1]}.data.${main_function:[label,orgin]}
  - integrate all training and testing files into
    - train.data.${main_function:\[label,orgin]}
    - test.data.${main_function:\[label,orgin]}
  - shuffle
    - #fw: train.data.${main_function:\[label,orgin]}.shuffle
    - #fw: test.data.${main_function:\[label,orgin]}.shuffle
    - append them and overwrite to the initial train.data.${main_function:\[label,orgin]}
   - create dict data file by putting in train.data.${main_function:\[label,orgin]}
     - #fw: zhi.dict.$main_function:\[label,orgin]
     ```
     $head -5 zhi.dict.$main_function:\[label,orgin]
     .       0
     the     1
     1       2
     and     3
     i       4
     ,       5
     ```
  - train
    - python src/main.py ../model $train_data_file $dict_data_file src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderDT train $batch_size
- Part 3: test
  -
- final output
  - sentiment.test.<label:[0,1]>.<method:[DeleteOnly,DeleteAndRetrieve,RetrieveOnly]>.<dataset:[yelp.amazon,captions]>
  ```
  $ head -5 sentiment.test.0.DeleteAndRetrieve.yelp
  ever since joes has changed hands it 's just gotten worse and worse .   ever since joes has changed hands it 's just so worth it .   0
  there is definitely not enough room in that part of the venue . there is definitely room in that i will continue to go out of the part .     0
  so basically tasted watered down .      so basically the food is always tasted fresh .  0
  she said she 'd be back and disappeared for a few minutes .     she said she 'd be back and would recommend it for a few hours .     0
  i ca n't believe how inconsiderate this pharmacy is .   this pharmacy is still the best in charlotte .  0
    
    
  $ head -5 sentiment.test.1.DeleteAndRetrieve.yelp
  it 's small yet they make you feel right at home .      it 's small yet they make you get it .  1
  i will be going back and enjoying this great place !    i will be going back and enjoying this garbage !        1
  the drinks were affordable and a good pour .    the only good thing about the drinks were pour .        1
  my husband got a ruben sandwich , he loved it . my husband got a ruben sandwich , it was way too salty .        1
  i signed up for their email and got a coupon .  i signed up for their email and got a coupon .  1
  ```
  



