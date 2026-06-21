import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                //  Верхняя панель
                HStack(spacing: 0) {
                    // Кнопка Назад
                    Button(action: { dismiss() }) {
                        Image("Icons/arrow")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    
                    // Круглая иконка ИИ
                    ZStack {
                        Circle()
                            .fill(viewModel.brandGradient)
                            .frame(width: 36, height: 36)
                        
                        Image("Icons/icon/Generate B-1")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    
                    // Название чата и дата под ним
                    // TODO: Временно hardcoding
                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Chat")
                            .font(.custom("Inter-Bold", size: 17))
                            .foregroundColor(.white)
                        
                        Text("26.03.2026")
                            .font(.custom("Inter-Regular", size: 11))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .padding(.leading, 12)
                    
                    Spacer()
                    
                    // Справа вверху кнопка
                    Button(action: { viewModel.changeModel() }) {
                        Image("Icons/Union")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .padding(10)
                    }
                    .padding(.trailing, 16)
                }
                .frame(height: 56)
                .background(Color(red: 0.07, green: 0.05, blue: 0.08))
                
                // Тонкий разделитель под навигатором
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
                
                //  Лента чата
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            if viewModel.messages.isEmpty {
                                Spacer().frame(height: 180)
                                VStack(spacing: 12) {
                                    HStack(spacing: 0) {
                                        Text("Your ").foregroundColor(.white)
                                        Text("AI assistant").foregroundStyle(viewModel.brandGradient)
                                        Text(" for anything").foregroundColor(.white)
                                    }
                                    .font(.custom("Inter-Bold", size: 22))
                                    
                                    Text("Ask questions, get answers, and explore ideas\nin seconds")
                                        .font(.custom("Inter-Regular", size: 14))
                                        .foregroundColor(.white.opacity(0.3))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(4)
                                        .padding(.horizontal, 32)
                                }
                            } else {
                                ForEach(viewModel.messages) { message in
                                    HStack(alignment: .bottom, spacing: 8) {
                                        if message.isUser { Spacer(minLength: 40) }
                                        
                                        // Иконка для ответов от ИИ (временно)
                                        if !message.isUser {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white.opacity(0.05))
                                                    .frame(width: 28, height: 28)
                                                Image("Icons/icon/Generate B-1")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 14, height: 14)
                                                    .foregroundColor(.white.opacity(0.4))
                                            }
                                        }
                                        
                                        Text(message.text)
                                            .font(.custom("Inter-Medium", size: 15))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(
                                                Group {
                                                    if message.isUser {
                                                        viewModel.brandGradient
                                                    } else {
                                                        Color.white.opacity(0.05)
                                                    }
                                                }
                                            )
                                            .cornerRadius(18)
                                        
                                        if !message.isUser { Spacer(minLength: 40) }
                                    }
                                    .padding(.horizontal, 16)
                                    .id(message.id)
                                }
                                
                                // Блок имитации мышления (Thinking, временно)
                                // TODO: В будущем подключить настоящую
                                if viewModel.isAiTyping {
                                    HStack(alignment: .bottom, spacing: 8) {
                                        // TODO: Иконку в будущем поменять
                                        ZStack {
                                            Circle()
                                                .fill(viewModel.brandGradient)
                                                .frame(width: 28, height: 28)
                                            Image("Icons/icon/Generate B-1")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 14, height: 14)
                                                .foregroundColor(.white)
                                        }
                                        
                                        // Те точки, которые надо будет заменить
                                        HStack(spacing: 4) {
                                            Circle().fill(Color.white).frame(width: 6, height: 6)
                                            Circle().fill(Color.white.opacity(0.4)).frame(width: 6, height: 6)
                                            Circle().fill(Color.white.opacity(0.2)).frame(width: 6, height: 6)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(18)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .id("typingIndicator")
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    // Слушатели для авто.прокрутки вниз
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastId = viewModel.messages.last?.id {
                            withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo(lastId, anchor: .bottom) }
                        }
                    }
                    .onChange(of: viewModel.isAiTyping) { _ in
                        if viewModel.isAiTyping {
                            withAnimation(.easeOut(duration: 0.25)) { proxy.scrollTo("typingIndicator", anchor: .bottom) }
                        }
                    }
                }
                
                // Input Bar
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 1)
                    
                    HStack(spacing: 12) {
                        // Кастомное поле ввода промпта
                        ZStack(alignment: .leading) {
                            if viewModel.inputText.isEmpty {
                                Text("Ask anything...")
                                    .font(.custom("Inter-Regular", size: 16))
                                    .foregroundColor(.white.opacity(0.2))
                                    .padding(.leading, 4)
                            }
                            
                            TextField("", text: $viewModel.inputText)
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.white)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .focused($isTextFieldFocused)
                        }
                        
                        Spacer()
                        
                        // Кнопка действия
                        if viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            //  Кнопка импорта
                            Image("Icons/vuesax/linear/import")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.4))
                                .frame(width: 36, height: 36)
                        } else {
                            // Кнопка отправки
                            Button(action: {
                                withAnimation(.spring()) {
                                    viewModel.sendMessage()
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(viewModel.brandGradient)
                                        .frame(width: 36, height: 36)
                                    
                                    Image("Icons/vuesax/linear/send-2")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 64)
                    .background(Color(red: 0.1, green: 0.08, blue: 0.12).opacity(0.5))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
}

#Preview {
    ChatView()
}
