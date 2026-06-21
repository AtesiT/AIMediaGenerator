import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // NavBar
                HStack {
                    Button(action: { dismiss() }) {
                        Image("Icons/arrow")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Text("AI Chat History")
                        .font(.custom("Inter-Bold", size: 17))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Заглушка, чтобы центрировать нормально (вместо spacer)
                    Color.clear
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 16)
                }
                .frame(height: 56)
                
                // Записи в истории
                if viewModel.sections.isEmpty {
                    Spacer()
                    VStack(spacing: 0) {
                        viewModel.brandGradient
                            .mask(
                                Image("Icons/icon/Magic pencil A")
                                    .resizable()
                                    .scaledToFit()
                            )
                            .frame(width: 56, height: 56)
                            .padding(.bottom, 24)
                        
                        Text("No chats yet")
                            .font(.custom("Inter-Bold", size: 28))
                            .foregroundColor(.white)
                            .padding(.bottom, 12)
                        
                        Text("Start a conversation to see\nyour history here")
                            .font(.custom("Inter-Regular", size: 15))
                            .foregroundColor(.white.opacity(0.4))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                    Spacer()
                } else {
                    // Лента истории
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ForEach(viewModel.sections) { section in
                                VStack(alignment: .leading, spacing: 14) {
                                    // Заголовок даты
                                    Text(section.title)
                                        .font(.custom("Inter-Bold", size: 20))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                    
                                    // Элементы внутри даты
                                    VStack(spacing: 12) {
                                        ForEach(section.items) { item in
                                            Button(action: { viewModel.openChat(item: item) }) {
                                                HistoryCardView(item: item, gradient: viewModel.brandGradient)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }
}

// Компонент отдельной ячейки истории
struct HistoryCardView: View {
    let item: HistoryItem
    let gradient: LinearGradient
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Иконка ИИ слева
            gradient
                .mask(
                    Image("Icons/icon/Generate B-1")
                        .resizable()
                        .scaledToFit()
                )
                .frame(width: 20, height: 20)
                .padding(.top, 2)
            
            // Текст сообщения + Время
            VStack(alignment: .leading, spacing: 4) {
                Text(item.previewText)
                    .font(.custom("Inter-Medium", size: 15))
                    .foregroundColor(.white)
                    .lineLimit(1) // Обрезка текста с троеточием
                    .multilineTextAlignment(.leading)
                
                Text(item.time)
                    .font(.custom("Inter-Regular", size: 11))
                    .foregroundColor(.white.opacity(0.3))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04)) // Темная скругленная подложка ячейки
        .cornerRadius(16)
    }
}

#Preview {
    HistoryView()
}
