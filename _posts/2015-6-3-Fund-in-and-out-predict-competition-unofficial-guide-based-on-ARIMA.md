---
layout: post  
title:  资金流入流出非官方指南--ARIMA入门  
date:   2015-06-03 15:47:00  
category: 机器学习  
permalink: Fund-in-and-out-predict-competition-unofficial-guide-based-on-ARIMA  
---  
##写在前面  
[比赛赛题](http://tianchi.aliyun.com/competition/introduction.htm?spm=5176.100066.333.4.oOVDaA&raceId=3)  
再次感谢[俏乡丽人的帖子](http://bbs.aliyun.com/read/244892.html?spm=5176.7189909.0.0.XHnEkx), 看到你的帖子之前一点思路都没有.  
本小弱非数据挖掘出身, 看过Andrew Ng 的公开课, 在看《数据挖掘导论》和《统计学习方法》，做过两次[阿里推荐算法比赛](http://appendix.cc/Alibaba_Recommand_Contest/).  
本文仿照[olibeater大神](http://oilbeater.com/index.html)的[阿里大数据竞赛非官方指南第三弹-- LR入门](http://oilbeater.com/%E9%98%BF%E9%87%8C%E5%A4%A7%E6%95%B0%E6%8D%AE%E6%AF%94%E8%B5%9B/2014/04/04/the-bigdata-race-3.html), 从时间序列(ARIMA)角度切入, 提供主要代码,   
>"帮助感兴趣的新手快速入手, 希望大家可以快速的参与进比赛来, 如果真的有帮助到某个同学的话, 那就苟富贵勿相忘了。"(引自[阿里大数据竞赛非官方指南](http://oilbeater.com/%E9%98%BF%E9%87%8C%E5%A4%A7%E6%95%B0%E6%8D%AE%E6%AF%94%E8%B5%9B/2014/03/16/the-setup-of-bigdata-race.html))  

##系统构建  
针对这次比赛,可以使用的工具主要有:  
1. Python(工具全面, 处理数据方便,但是时间序列分析方面略有不足)  
2. R(老牌数据挖掘语言, 时间序列方面工具比较全面)  
3. SQL(第二赛季应该主要是用SQL? )  
4. SPSS(图形化界面)  

题主主要使用Python(加上Numpy, Pandas和Statsmodels这几个库)进行数据的处理, 并使用R进行时间序列模型的构建.  
推荐一本书, [利用Python进行数据分析](http://book.douban.com/subject/25779298/)  
Python软件可以从[这](http://www.scipy.org/install.html)下载, 都包含了Python及科学计算的包,安装方便. 我使用的是[Pyzo](http://www.pyzo.org/).  
[R在这](http://www.r-project.org/), 还有[R的IDE](http://www.rstudio.com/).  


##挖掘过程  
####1. 利用Pandas读取及处理数据  


        import pandas as pd 
        user_balance = pd.read_csv('user_balance_table.csv', parse_dates = ['report_date'])
        timeGroup = user_balance.groupby(['report_date'])
        purchaseRedeemTotal = timeGroup['total_purchase_amt', 'total_redeem_amt'].sum()
        print(purchaseRedeemTotal)

 至此我们就成功地提取出来了数据中2013-07-01到2014-08-31中的时间序列, IPython中打印出来是这样的:  
 ![purchaseRedeemTotal](/images/purchaseRedeemTotal.jpg)

####2. 数据可视化  
Pandas的DataFrame对象可以直接打印出来


        purchaseRedeemTotal.plot()

 ![purchaseRedeemTotalPlot](/images/purchaseRedeemTotalPlot.png)
 
####3. ARIMA(p,q,d)选取  
 先根据[俏乡丽人的帖子](http://bbs.aliyun.com/read/244892.html?spm=5176.7189909.0.0.XHnEkx)中介绍的论文(参考文献第一篇 )和书籍对ARIMA有一个大致的了解,再进行应用.  
 以purchase为例, 核心代码如下:
####3.a 查看数据的ACF, PACF  


        purchase = purchaseRedeemTotal['total_purchase_amt']#选取purchase 
        from statsmodels.tsa.stattools import acf, pacf  
        purchaseACF = pd.DataFrame(acf(purchase))
        purchaseACF.plot(title = 'purchaseACF', kind = 'bar')
        purchasePACF = pd.DataFrame(pacf(purchase))
        purchasePACF.plot(title = 'purchasePACF', kind = 'bar')
 
 出来的图像是这样的:  
 ![purchaseACF](/images/purchaseACF.png)  
 ![purchasePACF](/images/purchasePACF.png)  
 此时观察两幅图, PACF较快衰减到0,  但是ACF并没有, 所以应该进行差分. 转到b.  

 若PACF和ACF都能大致符合要求,则转到c.  

####3.b 差分  

        purchaseDelta1 = delta1(purchase)
        purchaseDelta1.plot()
        def delta1(origin):
            delta1 = pd.Series(index = origin.index)
            delta1 = delta1[1 : ]
            for i in range(0, delta1.size):
                delta1[i] = origin[i + 1] - origin[i]
         return delta1
         
        purchaseDelta1 = delta1(purchase)
        purchaseDelta1.plot()
        
 此时purchaseDelta1变成这样:  
 ![purchaseDelta1](/images/purchaseDelta1.png)  


 这时回到a再次检验差分后的时间序列的ACF及PACF是否符合标准.  
 一次差分后的序列的ACF和PACF看起来是这样的:  
 ![purchaseDelta1ACF](/images/purchaseDelta1ACF.png)  
 ![purchaseDelta1PACF](/images/purchaseDelta1PACF.png)  
 比差分之前有所改善,让我们接着往下走.  
  
####3.c 选择p, q, 训练模型, 预测  
  
 d已经确定为1, 然后再看图猜数字, p根据PACF大概确定为7, q根据ACF选为5, 开始训练模型并预测  

        purchaseModel = ARIMA(purchase, [7, 1, 5]).fit()
        purchasePredict = purchaseModel.predict('2014-09-01', '2014-09-30')
        
 此时已经预测出九月份申购的情况了, 如图:  
 ![purchasePredict](/images/purchasePredict.png)  
  
####3.d 模型检验  
 可以把模型的残差取出来, 检验是否为白噪声. 如果是白噪声, 说明已经把原始时间序列中的信息都提取出来了, 模型是成功地, 否则反之.  
 还有其他方法,例如查看模型训练之后的AIC, BIC等,大家自己探索, 非统计学专业表示完全搞不明白什么意思.    
  
  
####注意事项  
只是这么做是比较粗糙的, 关于ARIMA, 除了把上面几个步骤做的更细以外, 还有其他细节, 例如  
1. 差分后还应当检验一下序列是不是被差分成白噪声了╮(╯▽╰)╭参考文献第一篇有提及
2. 可以在本地取出一个月做本地测试.  
 由于ARIMA属于统计类的模型,似乎做训练集测试集比较奇怪(未验证,知道的童鞋可以告诉我一下), 但是做做本地测试还是作用很大的, 能较好地把握模型的情况以及做其他改进.   
3. 关于(p, q, d)组值的选择.  
 有些选值组合会导致模型不稳定的情况, __需要强调的是__, 在Statsmodels中, 很多组值都会出现异常提示, 但是相同组值相同数据在R或者是SPSS中往往都能正常使用, 所以推荐大家可以结合R进行模型训练. Python中的Rpy2库可以实现在Python中调用R, 有需要可以看一下.  
  
  
##增长点  
比较小的点已经在↑面__注意事项__中说过了,接下来说说比较大方向的可以增长的地方.  
部分思路取自[俏乡丽人的帖子](http://bbs.aliyun.com/read/244892.html?spm=5176.7189909.0.0.XHnEkx).  
1. 使用组合预测方法, 融合模型, 模型差异越大效果越显著.  
 比如用不同时间段训练ARIMA再融合也可以, 用神经网络融合ARIMA也是可以的.  
2. 时间序列的其他方法, 比如GARCH.  
3. 神经网络, 这个就牛逼去了, 自由度也更大, 不仅可以用历史时间序列进行训练, 还可以结合其他特征, 比如[俏乡丽人的帖子](http://bbs.aliyun.com/read/244892.html?spm=5176.7189909.0.0.XHnEkx)提到的利率等, 还有一些论文中使用ARIMA训练后的残差. 而且预测时长也可以选择, 是一次30天还是滚动预测, 网络实现是BP还是GRNN等等. 还没实际做过, 大家可以一起试试. 
4. 最重要的最重要的最重要的, 是对数据更加深入的理解, 对数据不同角度的探索.  
 否则你只是从地上捡别人吃完西瓜之后掉下的西瓜子.  
这是我个人最弱的地方也是对自己最失望的地方.  
[俏乡丽人的帖子](http://bbs.aliyun.com/read/244892.html?spm=5176.7189909.0.0.XHnEkx)中提到过, 可以预测新增用户的影响, 或者是把新老用户分开预测, 再或者按照地区看看是不是某个地区会在某个特定时段出现资金的整体波动等, 这些都是通过对数据深入理解才能做到的, 也算是特征工程的一部分吧.  
5. 赛题中给的用户个人数据都还没使用, 暂时没有思路. 星座学怎么样(ˉ▽￣～)   

##写在后面  
1. 停止进步停止改进就是死亡. 过早陷入盲目调参的早晚要完蛋.  
 多试试不同的思路不同的角度, 才能真的学到更多收获更多.  
血淋淋的教训.  
2. 对数据更深的理解. 还有数据可视化很好很强大.  
3. 思想&算法是最重要的, 不要迷信工具也不要过度担心工具, 多看文档都能搞定.  
 但是有喜欢的工具还是很正常的哈哈毕竟用的熟了( ╯▽╰)    
4. 看论文. 作为一个本科小菜, 以前根本都不知道论文是什么!   
 自从看了论文就不行了, 都是别人实际做过的东西别人试过的方法, 能让你瞬间掌握多少知识少走多少弯路~ Google Scholar上面就写着__站在巨人的肩膀上__   每次压榨一篇论文的时候都会有种快感(づ｡◕‿‿◕｡)づ    
至于论文怎么来, 一般学校都会购买相关的数据库比如万方 知网等, 或者通过其他途径都能获取(比如买的话一篇三块钱).  __任何留邮箱(或求种)的都是耍流氓. __  
5. 关于我现在做的怎么样.   
 小菜鸡,昨晚刚突破100分大关(高兴了好久), 说不定明天又跌出去了. 分数不重要, 最重要的是什么? 是快乐! 哈哈, 是通过不断学习得到的快乐. 不过都是第三次参赛了, 这次如果能让我进进复赛的话我也是不会拒绝的, 毕竟能接触更多东西. 有做出其他什么来再继续发帖吧.  
6. 关于大环境. 听同学说过Kaggle的情况, 大家在论坛里面积极讨论问题或者共享代码, 但是在国内比如阿里这个比赛就...
 毕竟很多地方有差别, 但是还是希望大家能多多交流, 才能学到更多东西, 让阿里这个联赛的氛围更好.    

##参考(推荐)文献  
1. 基于时间序列分析的股票价格趋势预测研究-赵国顺.   (来自[俏乡丽人的帖子](http://bbs.aliyun.com/read/244892.html?spm=5176.7189909.0.0.XHnEkx)的推荐)  
2. 基于组合预测的风电场风速及风电机功率预测-张国强, 张伯民.  
 搜组合预测的时候无意中搜到的, 发现风电方面与实践序列相关的研究也不少. 这篇主要说了神经网络(分段线性法, 好像很高端, 暂时还没高明白)以及组合预测, 不过组合预测的公式好像有点问题大家可以再看看.   
3. 其他的就自己找着看吧, 想做什么找什么.  


###加油  
