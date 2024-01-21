CREATE PROCEDURE EvaluatePost
    @postId int,
    @userId int,
    @postMark int
AS
BEGIN
    BEGIN TRAN PostEvaluation

    INSERT PostRating(IdPost, IdUser, Mark)
    VALUES (@postId, @userId, @postMark)

    IF (@@ERROR != 0)
    BEGIN
        PRINT 'Error in post rating insert'
        ROLLBACK TRAN PostEvaluation
    END
    ELSE
    BEGIN
        PRINT 'Post rating insert successful'

        UPDATE Posts
        SET Rating = (
            SELECT CAST(SUM(Mark) AS float) / COUNT(*)
            FROM Posts INNER JOIN PostRating
            ON Posts.Id = PostRating.IdPost
            WHERE Posts.Id = @postId
        )
        WHERE Posts.Id = @postId

        IF (@@ERROR != 0)
        BEGIN
            PRINT 'Error in post rating update'
            ROLLBACK TRAN PostEvaluation
        END
        ELSE
        BEGIN
            PRINT 'Post rating update successful'

            UPDATE Users
            SET Rating = (
                SELECT CAST(SUM(Posts.Rating) AS float) / COUNT(*)
                FROM Users INNER JOIN Posts
                ON Users.Id = Posts.IdUser
                WHERE Users.Id = @userId
            )
            WHERE Users.Id = @userId

            IF (@@ERROR != 0)
            BEGIN
                PRINT 'Error in user rating update'
                ROLLBACK TRAN PostEvaluation
            END
            ELSE
            BEGIN
                PRINT 'User rating update successful'
                COMMIT TRAN PostEvaluation
            END
        END
    END
END




EXEC EvaluatePost 1, 2, 5

SELECT * FROM Users WHERE Id = 2;
