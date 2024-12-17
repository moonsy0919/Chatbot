//
//  ChatView.swift
//  chatbot
//
//  Created by 문시현 on 12/8/24.
//


import SwiftUI
import PDFKit

// ChatMessage 구조체
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool

    static func ==(lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text && lhs.isUser == rhs.isUser
    }
}

// ChatViewModel 클래스
class ChatViewModel: ObservableObject {
    @Published var chatMessages: [ChatMessage] = []
}

// ChatView
struct ChatView: View {
    @State private var userInput: String = ""
    @State private var isLoading: Bool = false
    @State private var selectedFile: URL? = nil
    @State private var isFileUploaderActive: Bool = false
    @State private var uploadStatus: String = "" // 파일 업로드 상태 표시
    @ObservedObject var viewModel = ChatViewModel()

    let apiService = APIService()

    // FileImporter를 사용하기 위한 상태 변수
    @State private var isFileImporterPresented = false

    var body: some View {
        NavigationView {
            VStack {
                // 좌측 상단 이미지 1번과 우측 상단 이미지 3번을 같은 행에 배치
                HStack {
                    Image("1") // 이미지 이름을 맞춰주세요.
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 60)
                        .padding(.leading, 10)
                    Spacer()
                    NavigationLink(destination: LazyView { SentimentAnalysisView() }) {
                        Image("3") // 감정 분석 아이콘
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 70)
                            .padding(4)
                            .cornerRadius(25)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing, 10)
                }
                .padding(.top, 10) // 상단 여백 추가

                // 파일 업로드 상태
                if !uploadStatus.isEmpty {
                    Text(uploadStatus)
                        .foregroundColor(.gray)
                        .padding()
                }

                // 메시지 스크롤
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.chatMessages) { message in
                                if message.isUser {
                                    HStack {
                                        Spacer()
                                        Text(message.text)
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(15)
                                            .frame(maxWidth: 250, alignment: .trailing) // 오른쪽 정렬
                                    }
                                } else {
                                    HStack {
                                        Image("2") // 챗봇 이미지
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .padding(.leading, 10)

                                        Text(message.text)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(15)
                                            .frame(maxWidth: 250, alignment: .leading) // 왼쪽 정렬

                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        // 새로운 메시지가 추가되면 스크롤
                        .onChange(of: viewModel.chatMessages) { _ in
                            if let lastMessage = viewModel.chatMessages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // 사용자 입력 텍스트 필드와 전송 버튼
                HStack {
                    // 파일 업로드 버튼
                    Button(action: {
                        // 파일 선택기를 표시
                        isFileImporterPresented.toggle()
                    }) {
                        Image(systemName: "paperclip") // 종이 클립 아이콘 (파일 첨부용)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .padding(10)
                    }
                    .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.plainText, .pdf, .image], onCompletion: { result in
                        switch result {
                        case .success(let url):
                            selectedFile = url // 선택된 파일의 URL을 저장
                            uploadStatus = "파일 선택됨: \(url.lastPathComponent)" // 업로드 상태 업데이트
                            print("Selected file: \(url)")
                            if url.pathExtension == "txt" {
                                readTextFile(url)
                            } else if url.pathExtension == "pdf" {
                                readPDFFile(url)
                            } else {
                                uploadStatus = "지원되지 않는 파일 형식입니다."
                            }
                        case .failure(let error):
                            print("File selection failed: \(error.localizedDescription)")
                            uploadStatus = "파일 선택에 실패했습니다: \(error.localizedDescription)"
                            // NSError 로 에러를 더 구체적으로 출력
                            if let nsError = error as? NSError {
                                print("Error domain: \(nsError.domain), code: \(nsError.code)")
                            }
                        }
                    })
                    
                    // 사용자 입력 텍스트 필드
                    TextField("질문을 입력하세요", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading, 20)
                        .padding(.vertical, 10)
                        .frame(maxHeight: 50)
                        .cornerRadius(25)
                        .disabled(isLoading)

                    Button(action: {
                        if !userInput.isEmpty {
                            sendPrompt()
                        }
                    }) {
                        Text(isLoading ? "전송 중..." : "전송")
                            .font(.system(size: 16, weight: .bold))
                            .padding(16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .frame(width: 60, height: 60)
                    }
                    .disabled(isLoading)
                    .offset(x: -10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }

    func sendPrompt() {
        guard !userInput.isEmpty else { return }
        isLoading = true
        let prompt = userInput
        userInput = ""

        // 사용자 질문을 chatMessages에 추가
        viewModel.chatMessages.append(ChatMessage(text: prompt, isUser: true))

        // 챗봇의 응답 준비 메시지를 추가 (답변 작성 중)
        viewModel.chatMessages.append(ChatMessage(text: "챗봇이 답변을 작성 중입니다...", isUser: false))

        Task {
            do {
                let response = try await apiService.sendPromptToGPT(prompt: prompt)
                await MainActor.run {
                    // 챗봇 응답 추가
                    // "챗봇이 답변을 작성 중입니다..." 메시지를 실제 응답으로 교체
                    if let index = viewModel.chatMessages.firstIndex(where: { $0.text == "챗봇이 답변을 작성 중입니다..." }) {
                        viewModel.chatMessages[index] = ChatMessage(text: response.trimmingCharacters(in: .whitespacesAndNewlines), isUser: false)
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    viewModel.chatMessages.append(ChatMessage(text: "에러: \(error.localizedDescription)", isUser: false))
                    isLoading = false
                }
            }
        }
    }

    // 텍스트 파일 읽기
    private func readTextFile(_ url: URL) {
        do {
            let text = try String(contentsOf: url)
            sendPromptWithFileContent(text)
        } catch {
            print("Error reading text file: \(error.localizedDescription)")
            uploadStatus = "텍스트 파일을 읽는 중 오류가 발생했습니다."
        }
    }
    
   

    

    // PDF 파일 읽기
    private func readPDFFile(_ url: URL) {
        guard let document = PDFDocument(url: url) else {
            print("Error: Unable to read PDF file.")
            uploadStatus = "PDF 파일을 읽는 중 오류가 발생했습니다."
            return
        }
        let text = document.string ?? ""
        sendPromptWithFileContent(text)
    }

    // 파일의 내용을 챗봇에게 전달
    private func sendPromptWithFileContent(_ content: String) {
        userInput = content
        sendPrompt()  // 파일 내용을 질문처럼 챗봇에게 전달
    }
}




