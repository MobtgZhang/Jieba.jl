using Pkg 
Pkg.activate("..")
using Jieba
using Test
# test segmentations
@info "Testing segment ..."
cutter = Jieba.worker()
seg_result = cutter <= "江州市长江大桥参加了长江大桥的通车仪式"
val_vec = ["江州", "市长", "江大桥", "参加", "了", "长江大桥", "的", "通车", "仪式"]
@test seg_result==val_vec
Jieba.delete_worker(cutter)
# test keywords
@info "Testing keywords extractor ..."
keywordser = Jieba.worker(worker_type="keywords")
val_vec = ["长江大桥" 22.3852549018; "江州" 8.6966709649; "通车" 7.97909923233; "仪式" 7.01721506556; "参加" 5.0710122193]
keywords_result = keywordser <= "江州市长江大桥参加了长江大桥的通车仪式"
@test keywords_result==val_vec
Jieba.delete_worker(keywordser)
# test pos tagger
@info "Testing postag ..."
tagger = Jieba.worker(worker_type="tag")
tag_result = tagger <= "江州市长江大桥参加了长江大桥的通车仪式"
val_vec = ["江州" "ns"; "市长" "n"; "江大桥" "20000"; "参加" "v"; "了" "ul"; "长江大桥" "ns"; "的" "uj"; "通车" "n"; "仪式" "n"]
@test tag_result==val_vec
Jieba.delete_worker(tagger)
# test simhash simhasher
@info "Testing simhash ..."
simhasher = Jieba.worker(worker_type="simhash")
simhash_result = simhasher <= "江州市长江大桥参加了长江大桥的通车仪式"
val_vec = (["长江大桥" 22.3852549018; "江州" 8.6966709649; "通车" 7.97909923233; "仪式" 7.01721506556; "参加" 5.0710122193], 0xb2c7e222481d8eb2)
@test simhash_result==val_vec
Jieba.delete_worker(simhasher)
@info "Test finished."

