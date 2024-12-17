//
//  SentimentAnalysisView.swift
//  chatbot
//
//  Created by 문시현 on 12/8/24.
//

import SwiftUI
import CoreML

struct SentimentAnalysisView: View {
    @State private var userInput = ""
    @State private var labelPrediction = ""
    @State private var behaviorExample = ""  // 행동 예시 추가
    @State private var model: SentimentAnalyzer2?  // 모델 변경

    var body: some View {
        VStack {
            Text("감정 분석기")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 100)
            
            Spacer()

            VStack {
                TextField("오늘 하루 있었던 일을 적어주세요 !", text: $userInput)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                
                Button(action: {
                    analyzeButtonTapped()
                }) {
                    Text("분석하기")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .background(Color.blue)
                        .cornerRadius(50)
                }
                .padding()

                Text(labelPrediction)
                    .padding()
                    .font(.largeTitle)
                
                ScrollView {  // ScrollView 추가
                    Text(behaviorExample)  // 행동 예시 출력
                        .padding()
                        .font(.title3)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)  // 텍스트 길이에 따라 자동 조정
                }
                .frame(maxHeight: 200)  // 최대 높이를 설정하여, 너무 길어지는 것을 방지
            }
            .padding(.horizontal, 30)
            .cornerRadius(10)
            .padding()

            Spacer()
        }
        .onAppear {
            // View가 나타날 때 모델을 초기화
            if model == nil {
                model = try? SentimentAnalyzer2()  // 모델 변경
            }
        }
    }

    private func analyzeButtonTapped() {
        guard let model = model else { return }  // 모델이 준비되었는지 확인
        let input = SentimentAnalyzer2Input(text: userInput)  // 모델 Input 클래스 사용
        
        guard let output = try? model.prediction(input: input) else {
            labelPrediction = "분석 실패"
            behaviorExample = ""
            return
        }
        
        // 감정 라벨에 따른 처리
        if output.label == "기쁨" {
            labelPrediction = "😀 기쁨"
            behaviorExample = "기쁨을 느낄 때는 친구와 함께 시간을 보내거나 좋아하는 활동을 하며 즐거운 시간을 보내는 것이 좋습니다!"
        } else if output.label == "슬픔" {
            labelPrediction = "🙁 슬픔"
            behaviorExample = "슬픔을 느낄 때는 마음을 열고 신뢰하는 사람과 대화하거나 자신에게 편안한 시간을 가지세요."
        } else if output.label == "불안" {
            labelPrediction = "😟 불안"
            behaviorExample = "불안을 느낄 때는 깊은 호흡을 하고, 잠시 휴식을 취하거나 차분한 음악을 듣는 것이 도움이 될 수 있습니다."
        } else if output.label == "분노" {
            labelPrediction = "😠 분노"
            behaviorExample = "분노를 느낄 때는 잠시 멈추고 깊은 호흡을 하거나, 운동을 하여 에너지를 분출하는 것이 유익할 수 있습니다."
        } else if output.label == "당황" {
            labelPrediction = "😳 당황"
            behaviorExample = "당황스러울 때는 잠시 상황을 정리하고, 상대방의 반응에 따라 차분히 대처하는 것이 좋습니다."
        } else {
            labelPrediction = "😐 중립/알 수 없음"
            behaviorExample = "이 감정은 중립적인 상태입니다. 상황에 따라 더 많은 정보를 바탕으로 판단할 수 있습니다."
        }
    }
}
