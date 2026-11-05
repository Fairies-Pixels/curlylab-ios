import SwiftUI

struct ReviewModalSheet: View {
    let product: Product
    @ObservedObject var viewModel: ProductsViewModel
    let onDismiss: () -> Void

    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var editingReview: Review?
    @State private var userId: UUID?
    @State private var username: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                productHeaderCard
                reviewFormCard
                reviewsSection
                Spacer().frame(height: 8)
            }
            .padding(24)
        }
        .background(Color(hex: "F8F4ED").ignoresSafeArea())
        .task {
            userId = viewModel.getCurrentUserId()
            username = viewModel.getCurrentUsername()
            await viewModel.loadReviews(product.id)
        }
    }

    private var productHeaderCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Color(hex: "F8F4ED")
                AsyncImage(url: product.imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Image("curly_wave").resizable().scaledToFit()
                    }
                }
            }
            .frame(width: 64, height: 64)
            .cornerRadius(16)
            .clipped()

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: "4A5B48"))
                    .lineLimit(2)
                    .truncationMode(.tail)

                Text("Отзывы о средстве")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "4A5B48").opacity(0.6))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var reviewFormCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(editingReview != nil ? "Редактировать отзыв" : "Оставить отзыв")
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(Color(hex: "4A5B48"))

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        rating = i
                    } label: {
                        Image(systemName: i <= rating ? "star.fill" : "star")
                            .font(.system(size: 24))
                            .foregroundColor(i <= rating ? Color(hex: "D4739A") : Color(hex: "4A5B48").opacity(0.3))
                            .frame(width: 40, height: 40)
                    }
                }
            }

            TextField("Ваш отзыв", text: $comment, axis: .vertical)
                .lineLimit(1...3)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "4A5B48"))
                .padding(12)
                .background(Color(hex: "F8F4ED"))
                .cornerRadius(16)

            if editingReview != nil {
                HStack(spacing: 12) {
                    Button {
                        editingReview = nil
                        rating = 0
                        comment = ""
                    } label: {
                        Text("Отменить")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(hex: "4A5B48"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "4A5B48").opacity(0.4), lineWidth: 1)
                            )
                    }

                    Button {
                        if let review = editingReview {
                            Task {
                                await viewModel.deleteReview(product.id, review.id)
                                editingReview = nil
                                rating = 0
                                comment = ""
                            }
                        }
                    } label: {
                        Text("Удалить")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "D4739A"))
                            .cornerRadius(16)
                    }
                }
            }

            Button {
                Task {
                    if let editing = editingReview {
                        await viewModel.updateReview(
                            productId: product.id,
                            reviewId: editing.id,
                            mark: rating,
                            reviewText: comment
                        )
                    } else {
                        await viewModel.submitReview(
                            productId: product.id,
                            mark: rating,
                            reviewText: comment
                        )
                    }
                    editingReview = nil
                    rating = 0
                    comment = ""
                }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(editingReview != nil ? "Обновить" : "Отправить")
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(hex: "728C6A"))
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(rating == 0 || comment.trimmingCharacters(in: .whitespaces).isEmpty || userId == nil)
            .opacity((rating == 0 || comment.trimmingCharacters(in: .whitespaces).isEmpty || userId == nil) ? 0.5 : 1)

            if let error = viewModel.error {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    @ViewBuilder
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Все отзывы")
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundColor(Color(hex: "4A5B48"))

                Spacer()

                Image(systemName: "star.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(hex: "728C6A").opacity(0.6))
            }
            .padding(.horizontal, 4)

            if viewModel.isLoading {
                ProgressView()
                    .tint(Color(hex: "728C6A"))
                    .frame(maxWidth: .infinity)
                    .padding()

            } else if viewModel.reviews.isEmpty {
                Text("Пока нет отзывов")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "4A5B48").opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.reviews) { review in
                        let isCurrentUserReview = review.userId == userId

                        ReviewItem(
                            review: review,
                            showMenu: isCurrentUserReview,
                            onEditClick: isCurrentUserReview ? { handleEdit(review) } : nil,
                            onDeleteClick: isCurrentUserReview ? { handleDelete(review) } : nil
                        )
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
            }
        }
    }

    private func handleEdit(_ review: Review) {
        editingReview = review
        rating = review.rating
        comment = review.comment
    }

    private func handleDelete(_ review: Review) {
        Task { await viewModel.deleteReview(product.id, review.id) }
    }
}
