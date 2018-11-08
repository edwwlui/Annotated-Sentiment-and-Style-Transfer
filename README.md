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
  - parameters
    ```
    dict_num
    dict_threshold
    dev_num
    algo_name: SeqToSeq, ChoEncoderDecoder, ChoEncoderDecoderTopic, ChoEncoderDecoderDT, ChoEncoderDecoderLm, TegEncoderDecoder, BiEncoderAttentionDecoder, BiEncoderAttentionDecoderStyle, LihangEncoderDecoder
    mode (method): train, generate, generate_b_v, generate_b_v_t, generate_b_v_t_v, generate_emb, generate_b_v_t_g, observe
    batch_size
    self.conf_dict = {
    'split_level': 'zi', 
    'pre_word_embedding': False,
    'word_embedding_dim': 128, 
    'n_topics': 5000, 
    'topic_embedding_dim': 256, 
    'max_sentence_word_num': 150,
    'min_sentence_word_num': 1, 
    'is_BEG': False, 
    'is_END': True,
    'hidden_dim': 512, 
    'charset': charset, 
    'shuffle': False,
    'save_freq': 100}
    ```
  - process
    - train
    - test
  - model_name
    - DeleteAndRetrieve
    - DeleteOnly
  - data_name
  
      |Dataset|dict_num|dict_threshold|dev_num|data name: 0|data name: 1|output name: 0|output name: 1|# of line|
      |---|---|---|---|---|---|---|---|---|
      |Yelp|7000|15|4000*|-ve|+ve|-ve to +ve|+ve to -ve|448259|
      |Amazon|10000|5.5|1000|-ve|+ve|-ve to +ve|+ve to -ve|557997|
      |Imagecaption|3000|5|2000|humorous|romantic|factual to romantic|factual to humorous|13600|
      |Formality||||||||224241|
- Part 1: configure
  - model_name -> $main_function
    - if $main_function=='DeleteOnly' then $main_function='label'
    - if $main_function=='DeleteAndRetrieve' or 'RetrieveOnly' then $main_function='orgin'
- Part 2: train 
  - get tf-idf score and Euclidean dist for Retrieve and n-gram for Delete from data 
    - #fw: sentiment.train.\[0,1].tf_idf.$main_function:\[label,orgin]
    ```
    the worst	2698.0
    worst	1187.5
    very disappointed	838.0
    ```
  - if data==amazon: use nltk to filter by tf-idf 
     - #overwrite: sentiment.train.${i:\[1,2]}.tf_idf.$main_function:\[label,orgin]
  - add data of attribute marker if pass the threshold specified 
  
    - #fw: sentiment.train.${i:\[0,1]}.data.${main_function:[label,orgin]}
    ```
    daily specials and ice cream which	they also have daily specials and ice cream which is really good .	they also have is really good .	1
    daily specials and ice cream which	they also have daily specials and ice cream which is really good .	they also have great is so good . 	1
    daily specials and ice cream which	they also have daily specials and ice cream which is really good .	they also make also really good . 	1
    ```
    - #fw: sentiment.dev.${i:\[0,1]}.data.${main_function:[label,orgin]}
    ```
    these donuts have texture and taste .	these donuts have the perfect texture and taste .	the perfect	1
    the price .	good food for the price .	good food for	1
    a little dirty on the inside , but that work there !	a little dirty on the inside , but wonderful people that work there !	wonderful people	1
    ```
  - integrate all training and testing files into
    - train.data.${main_function:\[label,orgin]}
    ```
    visiting this salon and come out looking .	i highly recommend visiting this salon and come out looking fabulous .	i highly recommend fabulous	1
    holy cow , this place was	holy cow , this place was good !	good time 	1
    ross is located in an outdoor strip mall .	ross is located in an outdoor strip mall .	self	1
    ```
    - test.data.${main_function:\[label,orgin]}
    ```
    windows have n't in years you can see scum on them .	windows have n't been cleaned in years you can see scum on them .	been cleaned	1
    waitresses are	waitresses are slow .	slow .	1
    just	just a mess avoid at all costs !	a mess avoid at all costs at all costs !	1
    ```
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
    - train in the mode of train
- Part 3: test
  - if data==TemplateBased:
    - get tf-idf score by n-gram from data
      
      #fw: sentiment.train.[0,1].tf_idf.$main_function:[label,orgin]

    - add data of attribute marker if pass the threshold specified
    
      #fw: sentiment.train.${i:[0,1]}.template1
     
      #fw: sentiment.test.${i:[0,1]}.template1
      
    - #mkdir sen1, sen0
    - retrieve according to tf_idf by whoosh and replace slot-placeholders
    
      #fw: sentiment.test.1.template1.result

      #fw: sentiment.test.0.template1.result
    - build output from the retrieved
      #fw: sentiment.test.${i:[0,1]}.template1.result.result and cp it to sentiment.test.${i:[0,1]}.${main_function:[label,orgin]}.${main_data:[yelp,amazon,imagecaption]}
  - preprocess
    - add data of attribute marker if pass the threshold specified 
      - #fw: sentiment.test.${i:\[0,1]}.data.${main_function:\[label,orgin]}
      ```
      ever since joes has changed hands it 's just	ever since joes has changed hands it 's just gotten worse and worse .	gotten worse worse and worse worse .	1
      there is definitely room in that part of the venue .	there is definitely not enough room in that part of the venue .	not enough	1
      so basically tasted	so basically tasted watered down .	watered down .	1
      ```
      
    - train with input files of ${test_file_prefix}${i}.template.${main_function} and ${train_file_prefix}${i}.template.${main_function} for the mode(method) of generate_emb
    ```
    sentiment.test.${i:[0,1]}.template.${main_function:[label,orgin]}
    ever since joes has changed hands it 's just	ever since joes has changed hands it 's just gotten worse and worse .	gotten worse worse and worse worse .	1
    there is definitely room in that part of the venue .	there is definitely not enough room in that part of the venue .	not enough	1
    so basically tasted	so basically tasted watered down .	watered down .	1
    
    sentiment.train.0.template.orgin
    nothing really special & not worthy of the $ tag .	nothing really special & not worthy of the $ _num_ price tag .	_num_ price	1
    second , the steak hoagie , it	second , the steak hoagie , it is atrocious .	is atrocious .	1
    i add cheese to the hoagie .	i had to pay $ _num_ to add cheese to the hoagie .	had to pay to pay $ _num_ $ _num_ to	1
    ```
    - find nearest neighbor with emb
      - #fw: sentiment.test.${i:\[0,1]}.template.$main_function:\[label,orgin].emb.result
      ```
      ever since joes has changed hands it 's just	ever since joes has changed hands it 's just gotten worse and worse .	gotten worse worse and worse worse .	1	0.508009486086	ever since the new folks took over this place	ever since the new folks took over this place has been wonderful .	has been wonderful been wonderful .	1
      ever since joes has changed hands it 's just	ever since joes has changed hands it 's just gotten worse and worse .	gotten worse worse and worse worse .	1	0.455706522823	ever since then , this restaurant has been my .	ever since then , this restaurant has been my guilty pleasure .	guilty pleasure	1
      ever since joes has changed hands it 's just	ever since joes has changed hands it 's just gotten worse and worse .	gotten worse worse and worse worse .	1	0.430749302283	ever since i tried sonic back in _num_ i have there food .	ever since i tried sonic back in _num_ i have loved there food .	loved	1
      ```
    - build output from the nearest neighbor
      - #fw: sentiment.test.${i:\[0,1]}.template.${main_function:\[label,orgin]}.emb.result.filter
      ```
      ever since joes has changed hands it 's just	ever since joes has changed hands it 's just gotten worse and worse .	has been wonderful been wonderful .	1	ever since the new folks took over this place has been wonderful .	0.508009486086
      ever since joes has changed hands it 's just	ever since joes has changed hands it 's just gotten worse and worse .	guilty pleasure	1	ever since then , this restaurant has been my guilty pleasure .	0.455706522823
      ever since joes has changed hands it 's just	ever since joes has changed hands it 's just gotten worse and worse .	loved	1	ever since i tried sonic back in _num_ i have loved there food .	0.430749302283
      ```
  - test
    - train in the mode of generate_b_v_t with input files of ${test_file_prefix}${i}.template.${main_function}.emb.result.filter
    - if RetrieveOnly
      - get retrieval result sentiment.test.{i:\[0,1]}.retrieval from sentiment.test.{i:\[0,1]}.template.orgin.emb.result.filter.result and cp to sentiment.test.${i:\[0,1]}.${main_function_orgin:\[DeleteOnly,DeleteAndRetrieve,RetrieveOnly]}.${main_data:\[yelp,amazon,imagecaption]}
    - foramt data from data/${main_data:[yelp,amazon,imagecaption]}/sentiment.train.${i:[0,1]}
    - shuffle the data and overwrite to sentiment.train.${i:[0,1]}.lm
    - create dict from the shuffle data
    - train in the mode of train
    - train in the mode of generate_b_v_t_v with the input file of ${test_file_prefix}0.template.${main_function}.emb.result.filter.result
    - get final result and overwrite to sentiment.test.${i:[0,1]}.${main_function_orgin:[DeleteOnly,DeleteAndRetrieve,RetrieveOnly]}.${main_data:[yelp,amazon,imagecaption]}
- final output
  - sentiment.test.<label:\[0,1]>.<method:\[DeleteOnly,DeleteAndRetrieve,RetrieveOnly]>.<dataset:\[yelp.amazon,captions]>
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
  # Modifications
  - debugging
    - tried "errors=ignore" instead of "errors=replace"
  - experiments
    
    - made theano.rc allow_downcast
  - solved
    - out of memory: smaller batch
  - abandoned changes
    - valueerrors: numpy
    - changed string.atoi to string.atof
