require_relative 'DBConnection'
require_relative 'user'

class Reply
    attr_accessor :id, :author_id, :question_id, :body, :parent_reply_id

    def initialize(options)
        @id = options['id']
        @author_id = options['author_id']
        @question_id = options['question_id']
        @parent_reply_id = options['parent_reply_id']
        @body = options['body']
    end

    def self.find_by_id(id)
        reply = DBConnection.instance.execute(<<~SQL, id)
            SELECT
                *
            FROM
                replies
            WHERE
                id = ?
        SQL

        Reply.new(reply.first) unless reply.empty?
    end

    def self.find_by_body(body)
        reply = DBConnection.instance.execute(<<~SQL, body)
            SELECT
                *
            FROM
                replies
            WHERE
                body = ?
        SQL

        Reply.new(reply.first) unless reply.empty?
    end

    def self.find_by_author_id(author_id)
        replies = DBConnection.instance.execute(<<~SQL, author_id)
            SELECT
                replies.*
            FROM
                replies
            WHERE
                author_id = ?
        SQL

        replies.map { |reply| Reply.new(reply) }
    end


    def self.find_by_question_id(question_id)
        replies = DBConnection.instance.execute(<<~SQL, question_id)
            SELECT
                replies.*
            FROM
                replies
            WHERE
                question_id = ?
        SQL

        replies.map { |reply| Reply.new(reply) }
    end

    def author
        User.find_by_id(self.author_id)
    end

    def question
        Question.find_by_id(self.question_id)
    end

    def parent_reply
        Reply.find_by_id(self.parent_reply_id)
    end

    def child_replies
        child_replies = DBConnection.instance.execute(<<~SQL, self.id)
            SELECT
                replies.*
            FROM
                replies
            WHERE
                parent_reply_id = ?
        SQL

        child_replies.map { |reply| Reply.new(reply)}
    end
end