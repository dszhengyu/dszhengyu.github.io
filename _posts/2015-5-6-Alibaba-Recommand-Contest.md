---
layout: post
title:  阿里推荐算法比赛总结
date:   2015-05-06 13:06:00
category: 机器学习
permalink: Alibaba_Recommand_Contest
---

###去年
今年是第二次参赛了，去年也啥都不会，但是用非常屌丝的规则，最后F1也才4多一点==惨不忍睹  
![2014](/images/2014.jpg)  
今年算是正正经经的参加，寒假看了Andrew Ng的Cousera的公开课，受益匪浅，so今年怒上模型。  
最开始LR，后来用RF和GBRT。  
换数据前一天F1达到8.76，排名427，首次突破前500的障碍。  
当时觉得一片光明有没有！睡觉的时候估计都是张着嘴笑不知道飞进去多少蚊子。  
换数据后还有五天，最开始下错数据，然后可能是之前分析数据没分析好，时间一天天逼近结果F1一直卡在8以下……最后就没戏了==    
![2015](/images/2015.jpg)  
就当学习了  
接下来先说说我的算法和系统结构，然后说说经验教训，最后是太懒没实现的   

---  

####算法及系统结构  
1. 时间分割  
简单分析后发现用户商品交互对最终是否购买，影响最大的就是前三天，占了70%左后，再往后影响越来越小，十天后几乎没有影响。  
仔细斟酌后选用了划窗取样，从第1天到第10天的作为特征提取，第11天打标签，第2天到第11天提取特征并用第12天打标签……以此类推。  
虽然有重叠（很大的重叠），但是有点哲学意味地觉得，两只脚不会踏进同一条河流之类，上面1到10天定位特征组1， 2到11为特征组2，虽然二者重叠九天，但是九天在组1是后九天，在第二组为前九天，更重要的是用来打标签的分别是第11天和第12天，根据我很小罗很不严谨的讨论一下，认为这样没问题==  
测试集随便选了一个十天，线上集用的最后十天数据提取特征再预测。  
总结，划窗取样有争议，也有可能是导致失败的原因，需要论证  
2. 特征工程
话说基本没有分析过数据==  
特征主要是三大类，U(用户), I(商品), UI(用户商品)    
具体可以参考[小斯的文章](http://weibo.com/p/1001603740163867054829)  
觉得他特征提取这部分的似乎复制粘贴到了他的很多篇文章，so如果你看了其中一篇就不用再看这篇了（特征提取部分）  
今年的字段比较多，增加了类别还有Geo。类别最后用上了一点但是效果不好，提取了商品在所在类别各项基本特征的占有率等。  
看过上届总决赛选手答辩的PDF，部分人使用的是系统特征等等  
也有人在训练LR时把user\_id和item\_id放进去，并且把所有的属性都dummy了，据说是总决赛队伍里面LR成绩做到最高的  
特征分析方面，只简单分析一下不同类别数据在同种特征下基本统计数据的不同（分均 方差 25% 50% 75%分布等），再用scikit-learn里面一些现成的东西，比如feature\_selection等现成的轮子，但是对统计学不是很懂所以用得不好，最后训练模型之后通过模型的feature\_importances_对比特征的重要程度。  
另外一个一直没有解决好的问题是两个分布不平均，第一个不平均的正负样本不平均，试了试降采样减少负样本；第二个不平均是训练时候因为采样导致的训练集和测试集的正负样本分布不一致。看了点论文，似乎都在讲第一个不一致，后一个不一致，如果模型很好的话是否就不攻自破了？  
总结，特征工程决定了成绩的80%，做得很差，特征不够健壮，换数据后成绩下跌应该也有一定关系。需要加强数据分析还有统计学方面的知识。  
3. 模型  
最开始只用LR，半死不活的F1只有2.几，用上RF后飙升到6，之后还用了GBRT，本地测试一直在6.5到7.2之间。  
但是对模型的了解不够，调参也都比较盲目，没有发挥出模型的全部威力。  
LR这种最简单的模型也用不好，基本功不够。  
模型融合方面只是简单投票，想试试先用LR过滤再用RF和GBRT，但是也没有实现==  
另外，传统方法是一个模型，还有方法是针对三种特征三个模型，也没试过==  
总结，多了解原理，多尝试，摸清模型的脾气  
4. 系统结构  
系统很简单三部分，Mysql分割总的UI集为十天一单位，[pandas](!http://pandas.pydata.org/)进行特征提取，模型方面用[scikit-learn](http://scikit-learn.org/stable/index.html)。  
感谢Python（虽然越来越不喜欢你 觉得很多方面含含糊糊的）  
感谢[pandas](!http://pandas.pydata.org/)强大的DataFrame, 感谢[Pyzo](http://www.pyzo.org/)提供的IDE  
最最感谢[scikit-learn](http://scikit-learn.org/stable/index.html)工具非常全，文档非常棒（虽然有的没及时更新有小错误），想好好学Python然后给你贡献代码。

###经验教训
1. 专业知识储备不足  
严重缺乏统计学和数据分析方面的知识，特征工程方面好像好好讲的书就不多，毕竟结合领域知识的话确实不好讲。  
多看书多实践认真读读别人写的博客以及相关论文。  
2. 过早优化，不肯改变，懒  
虽然脑子里有很多方法也懒得实现（见下面），比如Geo补全，聚类等，太早陷入模型调优，整天开着电脑跑模型，好像做了很多事其实什么都没做！  
不进则退，拥抱改变。  
3. 规则  
自己是“很不屑”规则的，但是看了《数据挖掘导论》才发现规则居然也算是一种算法==  
关键是怎么看吧，还是比较喜欢把规则内化为特征让模型自己选择  
4. 数据分布不一致  
似乎已经有不少这方面的研究  
自己研究的还不够细致吧，需要把论文等再好好看看  

###太懒没实现的
1. 数据清洗  
只有购买没有其他数据或者很少，也许是没有登录就购买或者是之前都在电脑上浏览过商品了
没有论证，但是清洗会导致数据的丢失，要仔细考虑并且论证  
2. 位置补全，聚类  
补全用户位置，再根据用户位置聚类或者简单方法推算出商品位置，再把商品和用户的距离作为特征进行训练，或者根据地理位置选择该地区热卖商品之类  
工程比较大，但是因为是本地服务，有一定的商品影响半径，应该是一个突破点  
3. LR，dummy属性集，这个说过  
4. 模型融合  
在一篇[人脸识别的论文](http://www.cs.cmu.edu/~efros/courses/LBMV07/Papers/viola-cvpr-01.pdf)里面看过，由于分布不均以及速度方面需要，用多个LR一层层把负样本滤除掉……很有意思，但还是没试过==    
5. 特征细化  
有关时间的特征基本上都是按天数记，是否可以试试重采样时间，精确到小时。  
需要比较好的数据分析来论证  

说多了都是泪  
让你不努力进不了前500  

---
接下来的打算  
1. 怒补基础知识  
《数据挖掘导论》分类部分快看完了  
《统计学习方法》李航的似乎很经典，还没看  
《模式分类》图书馆有  
2. 多看人家的经验总结  
3. 参加参加Kaggle  
觉得阿里的比赛大家还是功利性比较强吧，有个人放出了简单规则的代码作为baseline被喷的不像样还被主办方警告之类……  
Kaggle似乎大环境比较好，试着参加，多交流经验  
4. 5月15日，似乎第二场又要来了，支付宝资金流入流出预测  

感谢罗的陪伴，跟你讨论总是有所收获  
感谢女朋友的关心和理解，虽然不排除你的关心是为了30w哈哈哈，下一场就给你拿30w回来！  

####写完了都舒畅了好多，加油↖(^ω^)↗





