#!/bin/bash
#---part 1---
main_operation=$1
main_function=$2
main_data=$3
main_dict_num=$4
main_dict_thre=$5
main_dev_num=$6
#3rd arg, data_name
if [ "$main_data" = "amazon" ]; then
  batch_size=64
else
  batch_size=64
fi
#2nd arg, model_name
main_function_orgin=$main_function
if [ "$main_function" = "DeleteOnly" ]; then
main_function=label
elif [ "$main_function" = "DeleteAndRetrieve" ]; then
main_function=orgin
elif [ "$main_function" = "RetrieveOnly" ]; then
main_function=orgin
fi
#3rd arg, data_name
#-n -> not empty
#! -n -> empty
if [ "$main_data" = "yelp" ]; then
  if [ ! -n "$main_dict_num" ]; then
  main_dict_num=7000
  main_dict_thre=15
  fi
main_dev_num=4000

elif [ "$main_data" = "imagecaption" ]; then
  if [ ! -n "$main_dict_num" ]; then
  main_dict_num=3000
  main_dict_thre=5
  fi
main_dev_num=1000

elif [ "$main_data" = "amazon" ]; then
  if [ ! -n "$main_dict_num" ]; then
  main_dict_num=10000
  main_dict_thre=5.5
  fi
main_dev_num=2000
fi

main_category=sentiment
#positive/negative, humorous/romantic
main_category_num=2
#configure
preprocess_tool_path=src/tool/
data_path=data/
train_file_prefix=${main_category}.train.
dev_file_prefix=${main_category}.dev.
test_file_prefix=${main_category}.test.
orgin_train_file_prefix=${data_path}${main_data}/$train_file_prefix
orgin_dev_file_prefix=${data_path}${main_data}/$dev_file_prefix
orgin_test_file_prefix=${data_path}${main_data}/$test_file_prefix
train_data_file=train.data.${main_function}
test_data_file=test.data.${main_function}
dict_data_file=zhi.dict.${main_function}

#---part 2---

#1st arg=train
if [ "$main_operation" = "train" ]; then
	echo ">> starting training"

	#preprocess train data

  	#python src/tool/filter_style_ngrams.py data/${main_data:[yelp,amazon,imagecaption]}/sentiment.train. 2 $main_function:[label,orgin] sentiment.train.
	echo ">> python ${preprocess_tool_path}filter_style_ngrams.py $orgin_train_file_prefix $main_category_num $main_function $train_file_prefix"
	python ${preprocess_tool_path}filter_style_ngrams.py $orgin_train_file_prefix $main_category_num $main_function $train_file_prefix

	if [ "$main_data" = "amazon" ]; then
  	#use bash instead of sh, otherwise error: bad for loop var
  	#i<2
	for((i=0;i < $main_category_num; i++))
	do
          #python src/tool/use_nltk_to_filter.py sentiment.train.${i:[1,2]}.tf_idf.$main_function:[label,orgin]
	  #fw: sentiment.train.${i:[1,2]}.tf_idf.$main_function:[label,orgin].filter
          python ${preprocess_tool_path}use_nltk_to_filter.py ${train_file_prefix}${i}.tf_idf.$main_function
          #cp sentiment.train.${i:[1,2]}.tf_idf.${main_function:[label,orgin]}.filter sentiment.train.${i:[1,2]}.tf_idf.$main_function:[label,orgin]
          #overwrite
	  cp ${train_file_prefix}${i}.tf_idf.${main_function}.filter ${train_file_prefix}${i}.tf_idf.$main_function
	done
	fi

	for((i=0;i < $main_category_num; i++))
	do
          #python src/tool/preprocess_train.py data/${main_data:[yelp,amazon,imagecaption]}/sentiment.train.${i:[1,2]} sentiment.train.${i:[1,2]} ${main_function:[label,orgin]} ${main_dict_num:[7000,10000,3000]} ${main_dict_thre:[15,5.5,5]} sentiment.train.${i:[1,2]}
	  #fw: sentiment.train.${i:[1,2]}.data.operation
	  echo ">> python ${preprocess_tool_path}preprocess_train.py ${orgin_train_file_prefix}${i} ${train_file_prefix}${i} ${main_function} ${main_dict_num} ${main_dict_thre} ${train_file_prefix}${i}"
	  python ${preprocess_tool_path}preprocess_train.py ${orgin_train_file_prefix}${i} ${train_file_prefix}${i} ${main_function} ${main_dict_num} ${main_dict_thre} ${train_file_prefix}${i}
          #python src/tool/preprocess_train.py data/${main_data:[yelp,amazon,imagecaption]}/sentiment.dev.${i:[1,2]} sentiment.train.${i:[1,2]} ${main_function:[label,orgin]} ${main_dict_num:[7000,10000,3000]} ${main_dict_thre:[15,5.5,5]} sentiment.dev.${i:[1,2]}
          #fw: sentiment.dev.${i:[1,2]}.data.operation
	  python ${preprocess_tool_path}preprocess_test.py ${orgin_dev_file_prefix}${i} ${train_file_prefix}${i} $main_function $main_dict_num $main_dict_thre ${dev_file_prefix}${i}
	done
  	#cat sentiment.train.*.data.${main_function:[label,orgin]} >> train.data.${main_function:[label,orgin]}
	#fw
	cat ${train_file_prefix}*.data.${main_function} >> $train_data_file
	#cat sentiment.dev.*.data.${main_function:[label,orgin]} >> test.data.${main_function:[label,orgin]}
	#fw
	cat ${dev_file_prefix}*.data.${main_function} >> $test_data_file
	
	#shuffle and overwrite
	
  	#python src/tool/shuffle.py train.data.${main_function:[label,orgin]}
	#fw: train.data.${main_function:[label,orgin]}.shuffle
  	python ${preprocess_tool_path}shuffle.py $train_data_file
  	#python src/tool/shuffle.py test.data.${main_function:[label,orgin]}
	#fw: test.data.${main_function:[label,orgin]}.shuffle
	python ${preprocess_tool_path}shuffle.py $test_data_file
  	#cat test.data.$(main_function).shuffle >>train.data.${main_function:[label,orgin]}.shuffle
	#fw
	cat ${test_data_file}.shuffle >>${train_data_file}.shuffle
  	#cp train.data.$(main_function).shuffle $train.data.${main_function:[label,orgin]}
	#overwrite
	cp ${train_data_file}.shuffle ${train_data_file}
  	#python src/tool/create_dict.py $train.data.${main_function:[label,orgin]} $zhi.dict.$main_function:[label,orgin]
	#fw: zhi.dict.$main_function:[label,orgin]
	echo ">> python ${preprocess_tool_path}create_dict.py ${train_data_file} $dict_data_file"
	python ${preprocess_tool_path}create_dict.py ${train_data_file} $dict_data_file

  	#line_num of train.data.${main_function:[label,orgin]}
	line_num=$(wc -l < $train_data_file)
	vt=$main_dev_num
	echo ">> eval"
  	#BEGIN rule -> only execute once
  	#eval %.6f -> 6 decimal places
	eval $(awk 'BEGIN{printf "train_num=%.6f",'$line_num'-'$vt'}')
	test_num=$main_dev_num
	vaild_num=0
	eval $(awk 'BEGIN{printf "train_rate=%.6f",'$train_num'/'$line_num'}')
	eval $(awk 'BEGIN{printf "vaild_rate=%.6f",'$vaild_num'/'$line_num'}')
	eval $(awk 'BEGIN{printf "test_rate=%.6f",'$test_num'/'$line_num'}')

	#train process
  	#python src/main.py dir dialog_path $train.data.${main_function:[label,orgin]} $zhi.dict.$main_function:[label,orgin] train_rate valid_rate test_rate algo_name method 64
	echo "here is the training >> python src/main.py ../model $train_data_file $dict_data_file src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderDT train $batch_size"
	THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model $train_data_file $dict_data_file src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderDT train $batch_size
	echo ">> training ends"

#1st arg=test
elif [ "$main_operation" = "test" ]; then
	echo ">> start test"
	if true; then
		if [ "$main_function" = "TemplateBased" ]; then
			python ${preprocess_tool_path}filter_style_ngrams.py $orgin_train_file_prefix $main_category_num $main_function $train_file_prefix
			for((i=0;i < $main_category_num; i++))
			do
				echo ">> prepare_templatebased_data.py"
				python ${preprocess_tool_path}prepare_templatebased_data.py ${train_file_prefix}$i ${orgin_train_file_prefix}$i ${train_file_prefix}$i $main_dict_thre $main_dict_num
				python ${preprocess_tool_path}prepare_templatebased_data.py ${train_file_prefix}$i ${orgin_test_file_prefix}$i ${test_file_prefix}$i $main_dict_thre $main_dict_num
			done
			mkdir sen1
			mkdir sen0
			echo ">> retrieve_mode_my_1.py"
			python ${preprocess_tool_path}retrieve_mode_my_1.py
			python ${preprocess_tool_path}retrieve_mode_my_0.py
			for((i=0;i < $main_category_num; i++))
			do
				echo ">> build_templatebased.py"
				python ${preprocess_tool_path}build_templatebased.py ${test_file_prefix}${i}.template1.result ${orgin_test_file_prefix}${i}
				cp ${test_file_prefix}${i}.template1.result.result ${test_file_prefix}${i}.${main_function}.$main_data
			done

			exit
		fi


		#preprocess test data
    		#cp: cannot stat 'run-bash/*': No such file or directory
		cp run-bash/* ./
		line_num=$(wc -l < $train_data_file)
		vt=$main_dev_num
		echo ">> eval $(awk 'BEGIN{printf "train_num=%.6f",'$line_num'-'$vt'}')"
		eval $(awk 'BEGIN{printf "train_num=%.6f",'$line_num'-'$vt'}')
		test_num=$main_dev_num
		vaild_num=0
		eval $(awk 'BEGIN{printf "train_rate=%.6f",'$train_num'/'$line_num'}')
		eval $(awk 'BEGIN{printf "vaild_rate=%.6f",'$vaild_num'/'$line_num'}')
		eval $(awk 'BEGIN{printf "test_rate=%.6f",'$test_num'/'$line_num'}')
		for((i=0;i<$main_category_num;i++))
		do
		         echo ">> preprocess_test.py"
		         python ${preprocess_tool_path}preprocess_test.py ${orgin_test_file_prefix}${i} ${train_file_prefix}${i} $main_function $main_dict_num $main_dict_thre ${test_file_prefix}${i}
		         echo ">> filter_template_test.py"
		         python ${preprocess_tool_path}filter_template_test.py ${test_file_prefix}${i} ${main_function}
		         echo ">> filter_template.py"
		         python ${preprocess_tool_path}filter_template.py ${train_file_prefix}${i} ${main_function}
		done



		 for((i=0;i<$main_category_num;i++))
		 do
		 	echo ">> src/main.py"
		 	THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model $train_data_file $dict_data_file src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderDT generate_emb ${test_file_prefix}${i}.template.${main_function} $batch_size
		     THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model $train_data_file $dict_data_file src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderDT generate_emb ${train_file_prefix}${i}.template.${main_function} $batch_size
		 done

		 for((i=0;i<$main_category_num;i++))
		 do
		 	echo ">> find_nearst_neighbot_all.py"
		 	python ${preprocess_tool_path}find_nearst_neighbot_all.py $i $main_data ${main_function}
		 	python ${preprocess_tool_path}form_test_data.py ${test_file_prefix}${i}.template.${main_function}.emb.result
		 done

		echo ">> test preprocessed"
	fi


	#test process
	for((i=0;i<$main_category_num;i++))
	do
	echo ">> python src/main.py"
	THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model $train_data_file $dict_data_file src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderDT generate_b_v_t ${test_file_prefix}${i}.template.${main_function}.emb.result.filter $batch_size
	done
	if [ "$main_function_orgin" = "RetrieveOnly" ]; then
		echo ">> get_retrieval_result.py"
		python ${preprocess_tool_path}get_retrieval_result.py
		for((i=0;i<$main_category_num;i++))
		do
		cp ${test_file_prefix}${i}.retrieval ${test_file_prefix}${i}.${main_function_orgin}.$main_data
		done
		exit
	fi
	for((i=0;i<$main_category_num;i++))
	do
		echo ">> build_lm_data.py"
		python ${preprocess_tool_path}build_lm_data.py ${orgin_train_file_prefix}${i} ${train_file_prefix}${i}
		python ${preprocess_tool_path}shuffle.py ${train_file_prefix}${i}.lm
		cp ${train_file_prefix}${i}.lm.shuffle ${train_file_prefix}${i}.lm
		python ${preprocess_tool_path}create_dict.py ${train_file_prefix}${i}.lm ${train_file_prefix}${i}.lm.dict
	done
	for((i=0;i<$main_category_num;i++))
	do
		vaild_num=$i
		eval $(awk 'BEGIN{printf "vaild_rate=%.10f",'$vaild_num'/'$line_num'}')
		echo ">>THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model ${train_file_prefix}${i}.lm ${train_file_prefix}${i}.lm.dict src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderLm train $batch_size"
		THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model ${train_file_prefix}${i}.lm ${train_file_prefix}${i}.lm.dict src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderLm train $batch_size
	done
	vaild_num=0
	i=0
	eval $(awk 'BEGIN{printf "vaild_rate=%.10f",'$vaild_num'/'$line_num'}')
	echo ">> THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model ${train_file_prefix}${i}.lm ${train_file_prefix}${i}.lm.dict src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderLm generate_b_v_t_v ${test_file_prefix}1.template.${main_function}.emb.result.filter.result $batch_size"
	THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model ${train_file_prefix}${i}.lm ${train_file_prefix}${i}.lm.dict src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderLm generate_b_v_t_v ${test_file_prefix}1.template.${main_function}.emb.result.filter.result $batch_size
	vaild_num=1
	i=1
	eval $(awk 'BEGIN{printf "vaild_rate=%.10f",'$vaild_num'/'$line_num'}')

	echo ">>THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model ${train_file_prefix}${i}.lm ${train_file_prefix}${i}.lm.dict src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderLm generate_b_v_t_v ${test_file_prefix}0.template.${main_function}.emb.result.filter.result $batch_size"
	THEANO_FLAGS="${THEANO_FLAGS}" python src/main.py ../model ${train_file_prefix}${i}.lm ${train_file_prefix}${i}.lm.dict src/aux_data/stopword.txt src/aux_data/embedding.txt $train_rate $vaild_rate $test_rate ChoEncoderDecoderLm generate_b_v_t_v ${test_file_prefix}0.template.${main_function}.emb.result.filter.result $batch_size

	for((i=0;i<$main_category_num;i++))
	do

	    echo ">>python ${preprocess_tool_path}get_final_result.py ${test_file_prefix}${i}.template.${main_function}.emb.result.filter.result.result ${i}"
	    python ${preprocess_tool_path}get_final_result.py ${test_file_prefix}${i}.template.${main_function}.emb.result.filter.result.result ${i}
		cp ${test_file_prefix}${i}.template.${main_function}.emb.result.filter.result.result.final_result ${test_file_prefix}${i}.${main_function_orgin}.$main_data

	done

	fi
