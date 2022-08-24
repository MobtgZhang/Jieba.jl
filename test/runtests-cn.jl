# 测试分词
@info "测试分词 ..."
分词测试引擎 = Jieba.分词初始化()
分词测试结果 = 分词测试引擎 <= "江州市长江大桥参加了长江大桥的通车仪式"
分词预测结果 = ["江州", "市长", "江大桥", "参加", "了", "长江大桥", "的", "通车", "仪式"]
@test 分词测试结果==分词预测结果
Jieba.删除引擎(分词测试引擎)
# 测试关键词抽取
@info "测试关键词抽取 ..."
关键词测试引擎 = Jieba.分词初始化(引擎类型="关键词")
关键词测试结果 = 关键词测试引擎 <= "江州市长江大桥参加了长江大桥的通车仪式"
关键词预测结果 = ["长江大桥" 22.3852549018; "江州" 8.6966709649; "通车" 7.97909923233; "仪式" 7.01721506556; "参加" 5.0710122193]
@test 关键词测试结果==关键词预测结果
Jieba.删除引擎(关键词测试引擎)
# 测试词性标注
@info "测试词性标注 ..."
词性标注测试引擎 = Jieba.分词初始化(引擎类型="标记")
词性标注测试结果 = 词性标注测试引擎 <= "江州市长江大桥参加了长江大桥的通车仪式"
词性标注预测结果 = ["江州" "ns"; "市长" "n"; "江大桥" "20000"; "参加" "v"; "了" "ul"; "长江大桥" "ns"; "的" "uj"; "通车" "n"; "仪式" "n"]
@test 词性标注测试结果==词性标注预测结果
Jieba.删除引擎(词性标注测试引擎)
# 测试 simhash
@info "测试 simhash ..."
simhash引擎 = Jieba.分词初始化(引擎类型="simhash")
simhash测试结果 = simhash引擎 <= "江州市长江大桥参加了长江大桥的通车仪式"
simhash预测结果 = (["长江大桥" 22.3852549018; "江州" 8.6966709649; "通车" 7.97909923233; "仪式" 7.01721506556; "参加" 5.0710122193], 0xb2c7e222481d8eb2)
@test simhash测试结果==simhash预测结果
Jieba.删除引擎(simhash引擎)
@info "测试完成。"