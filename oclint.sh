#!/bin/bash



############ function ###########


#生成报告
reportAction(){

    ruleCommand="oclint-json-compilation-database -e Pods -- -report-type html 
    -rc CYCLOMATIC_COMPLEXITY=5 
    -rc TOO_MANY_PARAMETERS=8
    -rc NESTED_BLOCK_DEPTH=5
    -rc LONG_LINE=200 
    -rc NCSS_METHOD=50
    -rc LONG_VARIABLE_NAME=30 
    -rc SHORT_VARIABLE_NAME=2
    -rc LONG_CLASS=1500
    -rc LONG_METHOD=150
    -disable-rule ShortVariableName 
    -max-priority-1=10000 
    -max-priority-2=10000 
    -max-priority-3=10000"

    if [ -w "report.html" ];then

        eval $ruleCommand$">> report.html"

    else 
        eval $ruleCommand}$"> report.html"
    fi

}



############# Action ##############

project_name=$(ls | grep xcodeproj | awk -F.xcodeproj '{print $1}') #可以获取项目名

echo $"项目名称👉"[$project_name]

xcodebuild clean 

xcodebuild analyze | tee xcodebuild.log 

if [ $? -eq 0 ];then
    echo "✅ Analyze成功"

else 
    echo "❌ Analyze失败"
    echo ""
    exit 0  
fi
  

#oclint
oclint --version

if [ $? -eq 0 ];then
    echo "✅ oclint已安装"

else 
    echo "❌ oclint未安装"
    echo "🌐 oclint开始安装"
    brew tap oclint/formulae
    brew install oclint
fi

#xcpretty
xcpretty -v

if [ $? -eq 0 ];then

    echo "✅ Xcpretty已安装"

else

    echo "❌ Xcpretty未安装"
    echo "🌐 xcpretty开始安装"
    sudo gem install xcpretty

fi


xcodebuild |xcpretty -r json-compilation-database -o compile_commands.json 

oclint-xcodebuild 

reportAction

if [ $? -eq 0 ];then

    echo "✅ 分析成功"
    open report.html
else

    echo "❌ 分析失败"

fi

rm compile_commands.json 

exit 0